---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent:  Designing training datasets to test dynamical performance of ML emulators
  key: On/off Held-Suarez
layout: layouts/post.njk
---

The core of the Held-Suarez test case is specifying a zonally symmetric temperature profile `$$\bar{T}(\phi, \eta)$$` which does not vary with time. The time tendency
for traditional Held Suarez is constructed by choosing a relaxation timescale `$$k_T(\phi, \eta)$$` and letting `$$$\der{T}{t} = -k_T(\phi, \eta) (T(\lambda, \phi, \eta, t) - \bar{T}(\phi, \eta)) $$$`.
This corresponds to a linear relaxation to the reference temperature. The temperature forcing is loosely modeled off of
the change in temperature due to radiation that induces a equator-to-pole gradient in thermal energy.
To mimic the loss of kinetic energy to turbulent subgrid processes near the surface, the wind forcing is constructed by choosing a relaxation timescale `$$k_u(\eta)$$`
and letting `$$$\der{\boldsymbol{u}_h}{t} = - k_u(\eta) \boldsymbol{u}_h$$$`.

I think our first concrete goal for testing an idealized ML emulator should be to run a baroclinic wave. However, 
there is almost no reason to believe that an ML emulator  trained on Held-Suarez data would maintain a zonally symmetric steady state. 
Adiabatic flow will eventually die out due to energy lost to diffusion. Having a forcing that produces a quasi-equilibrated climate (such as Held-Suarez)
allows us to generate decades of training data in a single model run, without having to worry about splicing different runs together.
Therefore, I propose a simple change to the Held-Suarez forcing that should allow us to train ML emulators that can simulate the baroclinic wave.
The general principle is that 50% of the time, the HS forcing is turned on (and its strength is doubled), and 50% of the time, it is disabled and 
flow is entirely adiabatic. We design this as follows:

Let `$$ R$$` be a parameter specifying the suddenness with which HS forcing is enabled.  and let `$$P$$` be the period 
at which the forcing is turned on and off. For example, if `$$P = 24\textrm{ hours}$$`, then HS forcing is turned on for approximately 12 hours, and then turned off for approximately 12 hours, and `$$R$$`
determines how rapidly "night" falls. Since adiabatic tests can be run for around 30 days without noticable deterioration due to diffusion,
another promising choice would be `$$ P=60 \textrm{ days}$$`. In order to formalize the transition, let `$$t$$` be time,
and let `$$ \bar{t} = t/P - \lfloor t/P \rfloor $$` (i.e., the fraction of the current on/off cycle that has elapsed). Then let `$$d(\bar{t}) = \frac{\tanh\left( R\min(\bar{t}-0.25, -(\bar{t}-0.75)) \right)+1}{2}$$`. For `$$R=40$$`, this looks like [this](https://www.desmos.com/calculator/grqovnjjug). If we let `$$ N = \int_0^1 d(\bar{t}) \intd{\bar{t}}$$`, then the resulting forcing is 
`$$$ 
\begin{align*}
    \der{T}{t} &= -\left(\frac{d(\bar{t}) k_T }{N}\right) (T - \bar{T})\\
    \der{\boldsymbol{u}_h}{t} &= -\left(\frac{d(\bar{t}) k_u}{N} \right) \boldsymbol{u}_h.
\end{align*}
$$$`
The division by `$$N$$` ensures that the time integral of forcing (under the unrealistic assumption that `$$T, \boldsymbol{u}_h$$` are unrealistic) is the same 
over an on/off cycle as it is in base Held-Suarez. For the chosen form of `$$d(\bar{t})$$`, when `$$ R \gg 10$$`, `$$ N \approx 0.5$$`, implying that when 
the HS forcing is fully enabled, the point-wise physics tendencies are almost exactly twice as strong as in base Held-Suarez.

We have two options for how to turn this into training data. An ML emulator must have enough information in the training data
to distinguish between when the forcing is active, and when it is not. One strategy is to only pass the subsets of training snapshots 
in which `$$d(\bar{t}) \approx 0$$`. However, this creates temporal jumps in the data that we might be able to work around if `$$P=60 \textrm{ days}$$`, but not if `$$ P = 24 \textrm{ hours}$$`.However, within CAM we can output the `QRS` field, which contains the temperature forcing at each gridpoint either instantaneously or as a time average. Therefore, proving the vertical integral of `QRS` (calculated as static energy tendency, i.e. multiplied by `$$c_v$$`) can be fed into ML training frameworks as the total solar insolation. If averaged values are used, I would recommending providing the time average from the previous output interval, so that we are not passing in information that is derived over the atmospheric state during the interval that the emulator is simulating. I suspect that for our purposes, it would be sufficient to provide the vertically averaged snapshot the instantaneous snapshot of `$$QRS$$` at the initial state provided to the emulator.
