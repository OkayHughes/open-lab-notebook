---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Quasi-hydrostatic CAM-SE
  key: QHE-SE thermo
layout: layouts/post.njk
---
A number of things in `src/utils/cam_thermo.F90` need to change in order to create quasi-hydrostatic equilibrium.

The most immediate changes will be to `get_pmid_from_dp` and `get_gz`. We'll possibly need to change `get_rho_dry`, `get_ps`,
and `get_dp`.

This work involves two intermediate steps:
  * Implement QHE in reconstruction of geopotential (This should basically make AAM budget fine)
  * Add `$$\hat{r}^2$$` terms to pseudodensity, `$$\hat{r}$$` terms to prognostic equations
  
## List of subroutines and possible changes to make:
* `get_enthalpy_1hd`: **Is `dp` invoked correctly here? i.e.**
* `get_virtual_temp_1hd`: **Check that `dp` is being used correctly. Possible change to EOS?**
* `get_sum_species_1hd` **Check that `dp` is being used correctly.**
* `get_dp_1hd`: **Check if `dp` is being used correctly. Also, check whether invoked on physics side**
* `get_pmid_from_dp_1hd`: **Check if pmid is thermodynamic pressure in invocation. Addition of QHE terms? Modification of upper boundary?**
* `get_gz_given_dp_Tv_Rdry_1hd`: **MAJOR CHANGES**
* `get_ps_1hd`: **Ensure `dp` is consistent across physics/dynamics**
* `get_dp_ref_1hd`: **Check how this subroutine is used**
* `get_rho_dry_1hd`: **Likely several changes**
* `get_hydrostatic_energy_1hd` **Major changes, 


* `cam_thermo_init` No changes
* `cam_thermo_dry_air_update` no direct changes
* `cam_thermo_water_update` no direct changes
* `get_enthalpy_2h`: No direct changes
* `get_virtual_temp_2hd` no direct changes
* `get_sum_species_2hd`: No direct changes
* `get_dp_2hd`: No direct changes
* `get_pmid_from_dpdry_1hd`: No direct changes
* `get_exner_1hd`: No direct changes
* `get_virtual_theta_1hd`: No direct changes
* `get_gz_from_dp_dry_ptop_temp_1hd`: Little to no direct changes
* `get_gz_given_dp_Tv_Rdry_2hd`: No direct changes
* `get_Richardson_number_1hd`: No direct changes
* `get_ps_2hd`: No direct changes
* `get_kappa_dry_1hd`: No direct changes
* `get_kappa_dry_2hd`: No direct changes
* `get_dp_ref_2hd`: No direct changes
* `get_rho_dry_2hd`: No direct changes
* `get_molecular_diff_coef_1hd`: No direct changes for now
* `get_molecular_diff_coef_2hd`: No direct changes
* `get_molecular_diff_coef_reference` No changes
* `cam_thermo_calc_kappav_2hd`: Dear god, hopefully no changes

### Notes on `get_pmid_from_dp`:
