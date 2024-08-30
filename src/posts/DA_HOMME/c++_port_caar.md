npd---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  key: CaarFunctorImpl update
  parent: Porting DA HOMME to C++
layout: layouts/post.njk
---


## updating Caar
run() outlines the sequence of policies
  * m_policy_pre
  * m_plicy_post
  

  
### m_policy_pre
TagPreExchange

List of changes:
  * div_vdp
    * Need to access multiple levels phinh_i
    Idea: ThreadVectorRange(kv.team, NUM_LEV)
    * Idea: allocate buffer for DA?
  
  
  
### m_policy_post
  * TagPostExchange
