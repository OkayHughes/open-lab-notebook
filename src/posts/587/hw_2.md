---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: eecs587
  key: hw_2
layout: layouts/post.njk
---

Pseudocode:
Have master processor compute block decomposition.
Calculate block decomposition on local processor.
Allocate blocks + ghost cells 

Main loop:
  Communicate ghost cell values
  Calculate updated values
  
  
  
## First task: divide the domain
We want to be able to divide an `$$m\times n$$` matrix among
`$$p$$` processors, with minimal assumptions about divisibility.

Add outer calling routine which takes arbitrary `$$m', n'$$` and 
design inner method assuming `$$ m \geq n$$`


Divide horizontal stripes of matrix among processors. 

That is, assign `$$\lfloor \frac{m}{p} \rfloor $$` to each of the `$$p$$` processors. 
Because we are designing this algorithm for `$$p < \frac{\min(m', n')}{10} = \frac{1}{10}n $$` processors,
we therefore know that `$$ \frac{m}{p} \geq \frac{n}{p} > 10.$$` 


As an example, if we have 1000 rows and 16 processors, then 
we get `$$ \frac{1000}{16}= 62.5.$$` If we assign 62 rows to 
each processor then there are 8 rows left over. We know automatically that
the number of leftover rows is less than or equal to the total number of blocks.

This informs the following method of calculating responsibility of a row:
<details>
<summary>decomp_test.py</summary>

<pre>
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #f92672">import</span> <span style="color: #f8f8f2">numpy</span> <span style="color: #66d9ef">as</span> <span style="color: #f8f8f2">np</span>
<span style="color: #66d9ef">def</span> <span style="color: #a6e22e">starts_ends</span><span style="color: #f8f8f2">(NPROCS,</span> <span style="color: #f8f8f2">NROWS):</span>
    <span style="color: #f8f8f2">starts</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">[]</span>
    <span style="color: #f8f8f2">burden</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">[]</span>
    <span style="color: #f8f8f2">ends</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">[]</span>
    
    <span style="color: #f8f8f2">end_idx</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0</span> 
    <span style="color: #f8f8f2">base_rows_per_block</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">int(np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">floor(NROWS</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">NPROCS))</span>
    <span style="color: #f8f8f2">remainder</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">NROWS</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">base_rows_per_block</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">NPROCS</span>
    <span style="color: #66d9ef">for</span> <span style="color: #f8f8f2">rank_idx</span> <span style="color: #f92672">in</span> <span style="color: #f8f8f2">range(NPROCS):</span>
        <span style="color: #f8f8f2">start_idx</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">end_idx</span>
        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">remainder</span> <span style="color: #f92672">&gt;</span> <span style="color: #ae81ff">0</span><span style="color: #f8f8f2">:</span>
            <span style="color: #f8f8f2">end_idx</span> <span style="color: #f92672">+=</span> <span style="color: #f8f8f2">base_rows_per_block</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span>
            <span style="color: #f8f8f2">remainder</span> <span style="color: #f92672">-=</span> <span style="color: #ae81ff">1</span>
        <span style="color: #66d9ef">else</span><span style="color: #f8f8f2">:</span>
            <span style="color: #f8f8f2">end_idx</span> <span style="color: #f92672">+=</span> <span style="color: #f8f8f2">base_rows_per_block</span>
        <span style="color: #f8f8f2">starts</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">append(start_idx)</span>
        <span style="color: #f8f8f2">burden</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">append(end_idx</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">start_idx)</span>
        <span style="color: #f8f8f2">ends</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">append(end_idx)</span>
    <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">remainder</span> <span style="color: #f92672">&gt;</span> <span style="color: #ae81ff">0</span><span style="color: #f8f8f2">:</span>
        <span style="color: #66d9ef">raise</span> <span style="color: #a6e22e">ValueError</span><span style="color: #f8f8f2">(</span><span style="color: #e6db74">&quot;Remainder after division among processors is nonzero!&quot;</span><span style="color: #f8f8f2">)</span>
    <span style="color: #f8f8f2">print(starts)</span>
    <span style="color: #f8f8f2">print(ends)</span>
    <span style="color: #f8f8f2">print(burden)</span>


<span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">__name__</span> <span style="color: #f92672">==</span> <span style="color: #e6db74">&quot;__main__&quot;</span><span style="color: #f8f8f2">:</span>
    <span style="color: #f92672">from</span> <span style="color: #f8f8f2">sys</span> <span style="color: #66d9ef">import</span> <span style="color: #f8f8f2">argv</span>
    <span style="color: #f8f8f2">NPROCS</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">int(argv[</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">])</span>
    <span style="color: #f8f8f2">NROWS</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">int(argv[</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">])</span>
    <span style="color: #f8f8f2">starts_ends(NPROCS,</span> <span style="color: #f8f8f2">NROWS)</span>
</pre></div>

</pre>
</details>



Add if/else conditionals to handle lack of ghost entries at top and bottom of matrix.
Namely,
```

if my_rank == 0 :
  iteration_start_values = np.array(end_idx-start_idx + 1, NCOLUMNS)
  start_assignment_idx = 0
elif my_rank == MPI_SIZE-1:
  iteration_start_values = np.array(end_idx-start_idx + 1, NCOLUMNS)
  start_assignment_idx = 1
else:
  iteration_start_values = np.array(end_idx-start_idx + 2, NCOLUMNS)
  start_assignment_idx = 1
end_assignment_idx = start_assignment_idx + burden
  
```

Calculate initialization for my assigned rows:


