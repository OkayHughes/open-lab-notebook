---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: How does mpas do vertical velocity?
  parent: Baroclinic Wave Test Case with Topography
layout: layouts/post.njk
---

## reformulating latitude
```
!
!     pre-calculation z-metric terms in omega eqn.
!
      do iEdge = 1,nEdges
         cell1 = cellsOnEdge(1,iEdge)
         cell2 = cellsOnEdge(2,iEdge)
         if (cell1 <= nCellsSolve .or. cell2 <= nCellsSolve ) then 

            do k = 1, nVertLevels

               if (config_theta_adv_order == 2) then 

                  z_edge = (zgrid(k,cell1)+zgrid(k,cell2))/2. !edge height is mean of height of vertices

               else !theta_adv_order == 3 or 4 

                  d2fdx2_cell1 = deriv_two(1,1,iEdge) * zgrid(k,cell1) ! high order reconstruction uses several boundary halos
                  d2fdx2_cell2 = deriv_two(1,2,iEdge) * zgrid(k,cell2)
                  do i=1, nEdgesOnCell(cell1)
                     if ( cellsOnCell(i,cell1) > 0)       &    
                     d2fdx2_cell1 = d2fdx2_cell1 + deriv_two(i+1,1,iEdge) * zgrid(k,cellsOnCell(i,cell1))
                  end do
                  do i=1, nEdgesOnCell(cell2)
                     if ( cellsOnCell(i,cell2) > 0)       &    
                     d2fdx2_cell2 = d2fdx2_cell2 + deriv_two(i+1,2,iEdge) * zgrid(k,cellsOnCell(i,cell2))
                  end do     
     
                  z_edge =  0.5*(zgrid(k,cell1) + zgrid(k,cell2))         &    
                                - (dcEdge(iEdge) **2) * (d2fdx2_cell1 + d2fdx2_cell2) / 12.  

                  if (config_theta_adv_order == 3) then 
                     z_edge3 =  - (dcEdge(iEdge) **2) * (d2fdx2_cell1 - d2fdx2_cell2) / 12.   
                  else 
                     z_edge3 = 0. 
                  end if

               end if

                  zb(k,1,iEdge) = (z_edge-zgrid(k,cell1))*dvEdge(iEdge)/areaCell(cell1) 
                  zb(k,2,iEdge) = (z_edge-zgrid(k,cell2))*dvEdge(iEdge)/areaCell(cell2) 
                  zb3(k,1,iEdge)=  z_edge3*dvEdge(iEdge)/areaCell(cell1) 
                  zb3(k,2,iEdge)=  z_edge3*dvEdge(iEdge)/areaCell(cell2) 
  
            end do

         end if
       end do
!     for including terrain
      w(:,:) = 0.0
      rw(:,:) = 0.0

!
!     calculation of omega, rw = zx * ru + zz * rw
!

      do iEdge = 1,nEdges

         cell1 = cellsOnEdge(1,iEdge)
         cell2 = cellsOnEdge(2,iEdge)

         if (cell1 <= nCellsSolve .or. cell2 <= nCellsSolve ) then
         do k = 2, nVertLevels
            flux =  (fzm(k)*ru(k,iEdge)+fzp(k)*ru(k-1,iEdge))
            rw(k,cell2) = rw(k,cell2) + (fzm(k)*zz(k,cell2)+fzp(k)*zz(k-1,cell2))*zb(k,2,iEdge)*flux
            rw(k,cell1) = rw(k,cell1) - (fzm(k)*zz(k,cell1)+fzp(k)*zz(k-1,cell1))*zb(k,1,iEdge)*flux

            if (config_theta_adv_order ==3) then
               rw(k,cell2) = rw(k,cell2)    &
                                            - sign(1.0_RKIND,ru(k,iEdge))*config_coef_3rd_order* &
                                              (fzm(k)*zz(k,cell2)+fzp(k)*zz(k-1,cell2))*zb3(k,2,iEdge)*flux
               rw(k,cell1) = rw(k,cell1)    &
                                            + sign(1.0_RKIND,ru(k,iEdge))*config_coef_3rd_order* &
                                              (fzm(k)*zz(k,cell1)+fzp(k)*zz(k-1,cell1))*zb3(k,1,iEdge)*flux
            end if

         end do
         end if

      end do


```