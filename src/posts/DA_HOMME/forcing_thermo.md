---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Thermo forcing
layout: layouts/post.njk
---

```
  subroutine applyCAMforcing_tracers(elem,hvcoord,np1,np1_qdp,dt,adjustment)
  !
  ! Apply forcing to tracers
  !    adjustment=1:  apply forcing as hard adjustment, assume qneg check already done
  !    adjustment=0:  apply tracer tendency
  ! in both cases, update PS to conserve mass
  !
  ! For theta model, convert temperature tendency to theta/phi tendency
  ! this conversion is done assuming constant pressure except for changes to hydrostatic
  ! pressure from the water vapor tendencies. It is thus recomputed whenever
  ! water vapor tendency is applied
  ! 
  ! theta model hydrostatic requires this constant pressure assumption due to 
  ! phi/density being diagnostic.  theta model NH could do the conversion constant 
  ! density which would simplify this routine
  !
  ! NOTE about ps_v/dp3d
  ! init:
  !   (both ps_v and dp3d are valid)
  ! do: 
  !    physics  (uses ps_v to compute pressure levels. doesn't change ps_v)
  !    applyCAMforcing_tracers  use ps_v for initial pressure.  
  !                             may adjust dp3d for mass conservation (if adjust_ps=.false.)
  !                             ps_v no longer valid
  !    dynamics                 should only use dp3d
  !    remap                    remap back to ref levels.  ps_v now valid
  !    write restart files      ps_v ok for restart
  !
  use control_mod,        only : use_moisture, dt_remap_factor
  use hybvcoord_mod,      only : hvcoord_t
  use deep_atm_mod, only: r_hat_from_phi, quasi_hydrostatic_terms
#ifdef MODEL_THETA_L
  use control_mod,        only : theta_hydrostatic_mode
  use physical_constants, only : cp, gravit, kappa, Rgas, p0, rearth
  use element_ops,        only : get_temperature, get_r_star, get_hydro_pressure
  use eos,                only : pnh_and_exner_from_eos
#ifdef HOMMEXX_BFB_TESTING
  use bfb_mod,            only : bfb_pow
#endif
#endif
  implicit none
  type (element_t),       intent(inout) :: elem
  real (kind=real_kind),  intent(in)    :: dt
  type (hvcoord_t),       intent(in)    :: hvcoord
  integer,                intent(in)    :: np1,np1_qdp
  logical,                intent(in)    :: adjustment

  ! local
  integer :: i,j,k,q
  real (kind=real_kind)  :: fq
  real (kind=real_kind)  :: dp(np,np,nlev), ps(np,np), dp_adj(np,np,nlev)
  real (kind=real_kind)  :: phydro(np,np,nlev)  ! hydrostatic pressure
  logical :: adjust_ps   ! adjust PS or DP3D to conserve dry mass
#ifdef MODEL_THETA_L
  real (kind=real_kind)  :: pprime(np,np,nlev)
  real (kind=real_kind)  :: vthn1(np,np,nlev)
  real (kind=real_kind)  :: tn1(np,np,nlev)
  real (kind=real_kind)  :: pnh(np,np,nlev)
  real (kind=real_kind)  :: phi_n1(np,np,nlevp)
  real (kind=real_kind)  :: rstarn1(np,np,nlev)
  real (kind=real_kind)  :: exner(np,np,nlev)
  real (kind=real_kind)  :: dpnh_dp_i(np,np,nlevp)
  real (kind=real_kind)  :: r_hat(np,np)
#endif

#ifdef HOMMEXX_BFB_TESTING
  ! BFB comparison with C++ requires to perform the reduction
  ! of FQ over the whole column *before* adding to ps
  real (kind=real_kind) :: sum_fq(np,np)
  sum_fq = 0
#endif

  call t_startf("ApplyCAMForcing_tracers")

#ifdef MODEL_THETA_L
  if (dt_remap_factor==0) then
     adjust_ps=.true.   ! stay on reference levels for Eulerian case
  else
#ifdef SCREAM
     adjust_ps=.false.  ! Lagrangian case can support adjusting dp3d or ps
#else
     adjust_ps=.true.   ! Lagrangian case can support adjusting dp3d or ps
#endif
  endif
#else
  adjust_ps=.true.      ! preqx requires forcing to stay on reference levels
#endif

  dp=elem%state%dp3d(:,:,:,np1)
  dp_adj=dp
  ps=elem%state%ps_v(:,:,np1)
  !ps=hvcoord%hyai(1)*hvcoord%ps0 + sum(dp(:,:,:),3) ! introduces roundoff

  ! after calling this routine, ps_v may not be valid and should not be used
  elem%state%ps_v(:,:,np1)=0

#ifdef MODEL_THETA_L
   !compute temperatue and NH perturbation pressure before Q tendency
   do k=1,nlev
      phydro(:,:,k)=hvcoord%ps0*hvcoord%hyam(k) + ps(:,:)*hvcoord%hybm(k)
   enddo

   !one can set pprime=0 to hydro regime but it is not done in master
   !compute pnh, here only pnh is needed
   call pnh_and_exner_from_eos(hvcoord,elem%state%vtheta_dp(:,:,:,np1),dp,&
        elem%state%phinh_i(:,:,:,np1),pnh,exner,dpnh_dp_i)
   do k=1,nlev
      pprime(:,:,k) = pnh(:,:,k)-phydro(:,:,k)
   enddo
   call get_R_star(rstarn1,elem%state%Q(:,:,:,1))
   tn1=exner* elem%state%vtheta_dp(:,:,:,np1)*(Rgas/rstarn1) / dp
#endif

   if (adjustment) then 

      ! hard adjust Q from physics.  negativity check done in physics
      do k=1,nlev
         do j=1,np
            do i=1,np
               do q=1,qsize
                  ! apply forcing to Qdp
                  ! dyn_in%elem(ie)%state%Qdp(i,j,k,q,tl_fQdp) = &
                  !        dyn_in%elem(ie)%state%Qdp(i,j,k,q,tl_fQdp) + fq 
                  elem%state%Qdp(i,j,k,q,np1_qdp) = &
                       dp(i,j,k)*elem%derived%FQ(i,j,k,q)
                  
                  if (q==1) then
                     fq = dp(i,j,k)*( elem%derived%FQ(i,j,k,q) -&
                          elem%state%Q(i,j,k,q))
                     ! force ps to conserve mass:  
#ifdef HOMMEXX_BFB_TESTING
                     sum_fq(i,j) = sum_fq(i,j) + fq
#else
                     ps(i,j)=ps(i,j) + fq
#endif
                     dp_adj(i,j,k)=dp_adj(i,j,k) + fq   !  ps =  ps0+sum(dp(k))
                  endif
               enddo
            end do
         end do
      end do
#ifdef HOMMEXX_BFB_TESTING
      do j=1,np
        do i=1,np
          ps(i,j) = ps(i,j) + sum_fq(i,j)
        end do
      end do
#endif
   else ! end of adjustment
      ! apply forcing to Qdp
      elem%derived%FQps(:,:)=0
      do q=1,qsize
         do k=1,nlev
            do j=1,np
               do i=1,np
                  fq = dt*elem%derived%FQ(i,j,k,q)
                  if (elem%state%Qdp(i,j,k,q,np1_qdp) + fq < 0 .and. fq<0) then
                     if (elem%state%Qdp(i,j,k,q,np1_qdp) < 0 ) then
                        fq=0  ! Q already negative, dont make it more so
                     else
                        fq = -elem%state%Qdp(i,j,k,q,np1_qdp)
                     endif
                  endif
                  elem%state%Qdp(i,j,k,q,np1_qdp) = elem%state%Qdp(i,j,k,q,np1_qdp)+fq
                  if (q==1) then
                     elem%derived%FQps(i,j)=elem%derived%FQps(i,j)+fq/dt
                     dp_adj(i,j,k)=dp_adj(i,j,k) + fq
                  endif
               enddo
            enddo
         enddo
      enddo

      ! to conserve dry mass in the precese of Q1 forcing:
      ps(:,:) = ps(:,:) + dt*elem%derived%FQps(:,:)
   endif ! if adjustment


   if (use_moisture) then
      ! compute water vapor adjusted dp3d:
      if (adjust_ps) then
         ! compute new dp3d from adjusted ps()
         do k=1,nlev
            dp_adj(:,:,k) = (( hvcoord%hyai(k+1) - hvcoord%hyai(k) )*hvcoord%ps0 + &
                 ( hvcoord%hybi(k+1) - hvcoord%hybi(k))*ps(:,:))
         enddo
      endif
      elem%state%dp3d(:,:,:,np1)=dp_adj(:,:,:)
   endif

   ! Qdp(np1) was updated by forcing - update Q(np1)
   do q=1,qsize
      elem%state%Q(:,:,:,q) = elem%state%Qdp(:,:,:,q,np1_qdp)/elem%state%dp3d(:,:,:,np1)
   enddo
   

#ifdef MODEL_THETA_L
   if (use_moisture) then
      ! compute updated pnh and exner
      if (adjust_ps) then
         ! recompute hydrostatic pressure from ps
         do k=1,nlev  
            phydro(:,:,k)=hvcoord%ps0*hvcoord%hyam(k) + ps(:,:)*hvcoord%hybm(k)
         enddo
      else
         ! recompute hydrostatic pressure from dp3d
         call get_hydro_pressure(phydro,elem%state%dp3d(:,:,:,np1),hvcoord)
      endif
      do k=1,nlev
         pnh(:,:,k)=phydro(:,:,k) + pprime(:,:,k)
#ifdef HOMMEXX_BFB_TESTING
         exner(:,:,k)=bfb_pow(pnh(:,:,k)/p0,Rgas/Cp)
#else
         exner(:,:,k)=(pnh(:,:,k)/p0)**(Rgas/Cp)
#endif
      enddo
   endif
   
   !update temperature
   call get_R_star(rstarn1,elem%state%Q(:,:,:,1))
   tn1(:,:,:) = tn1(:,:,:) + dt*elem%derived%FT(:,:,:)
   
   
   ! now we have tn1,dp,pnh - compute corresponding theta and phi:
   vthn1 =  (rstarn1(:,:,:)/Rgas)*tn1(:,:,:)*elem%state%dp3d(:,:,:,np1)/exner(:,:,:)
     
   phi_n1(:,:,nlevp)=elem%state%phinh_i(:,:,nlevp,np1)
   do k=nlev,1,-1
      phi_n1(:,:,k)=phi_n1(:,:,k+1) + Rgas*vthn1(:,:,k)*exner(:,:,k)/pnh(:,:,k)
   enddo
   
   !finally, compute difference for FVTheta
   ! this method is using new dp, new exner, new-new r*, new t
   elem%derived%FVTheta(:,:,:) = &
        (vthn1 - elem%state%vtheta_dp(:,:,:,np1))/dt
   
   elem%derived%FPHI(:,:,:) = &
        (phi_n1 - elem%state%phinh_i(:,:,:,np1))/dt
   
#endif

  call t_stopf("ApplyCAMForcing_tracers")

  end subroutine applyCAMforcing_tracers
```

```
  subroutine get_hydro_pressure(p,dp,hvcoord)
  !
  implicit none

  real (kind=real_kind), intent(out)  :: p(np,np,nlev)
  real (kind=real_kind), intent(in)   :: dp(np,np,nlev)
  type (hvcoord_t),     intent(in)    :: hvcoord                      ! hybrid vertical coordinate struct

  integer :: k
  real(kind=real_kind), dimension(np,np,nlevp) :: p_i 

  p_i(:,:,1)=hvcoord%hyai(1)*hvcoord%ps0
  do k=1,nlev  ! SCAN
     p_i(:,:,k+1)=p_i(:,:,k) + dp(:,:,k)
  enddo
#ifdef HOMMEXX_BFB_TESTING
  do k=1,nlev
     p(:,:,k) = (p_i(:,:,k+1)+p_i(:,:,k))/2
  enddo
#else
  do k=1,nlev
     p(:,:,k)=p_i(:,:,k) + dp(:,:,k)/2
  enddo
#endif


  end subroutine get_hydro_pressure
```