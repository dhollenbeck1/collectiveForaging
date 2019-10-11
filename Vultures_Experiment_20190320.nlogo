;;                     Vultures - ver3
;;                     (USER VERSION) - In Development
;;
;;   Derek Hollenbeck, Taran Rallings, Daniel Schloesser,
;;   Chris Kello, and YangQuan Chen
;;   University of California, Merced
;;
;;   EMAIL: dhollenbeck@ucmerced.edu
;; =============================================================
;; This algorithm simulates vultures flocking and foraging for food in an
;; effort to understand foraging dynamics. There are two main variables:
;; correlation and cohesion. Correlation is the averaging of flockmates
;; headings with the current vulture with a vision distance. Coheion is
;; force the vulture feels with its neighbors under a Lennard-Jones Potential
;; control law.
;;
;; The user takes control of one of the vultures with a known visual radius
;; highlighted in green circle. The user cannot see beyond this unless there
;; are other vultures inside the visual distance.
;;
;; This work was supported by the National Science Foundation
;; NRT Intelligent Adaptive Systems.
;; ==============================================================

breed [ user the-user ]
breed [ vultures a-vulture ]
breed [ sheep a-sheep ]
breed [ vision-boundary a-vision-boundary ]

globals [
  population vision vision-food cohesion-dist
  minimum-separation max-align-turn max-cohere-turn max-separate-turn
  users-on cohesion-on alignment-on smoothing-on
  mov-spd turn-angle
  color-bkg color-tar color-vulture color-descend color-user
  size-of-map size-of-patch size-of-agent
  alpha epsilon gamma R
  xcor-tar ycor-tar reset-tar hp-tar hp-current eating-dist tar-count tar-count-end
  xcor-user ycor-user
  tempx tempy
  ljp-alpha ljp-beta ljp-well-depth
  vultures-descending vulture-gain
  tic-int-count tic-eat-count user-eat-count user-head
  tic-max tic-eat-user
  t2d-start t2d-on t2d user-t2d-start user-t2d-on user-t2d avg-t2d user-avg-t2d
  t2e-start t2e-on t2e user-t2e-start user-t2e-on user-t2e avg-t2e user-avg-t2e
  group-eff eff-scale
  user-eff
  sij-lim
  mouse-always-down
  len tot-len
  user-heading-change
]

turtles-own [
  flockmates
  old-heading heading-change
  cohesionmates
  nearby-sheep
  wake
  following
  alone
  nearest-neighbor
  nearest-sheep
  descending
  feasting
  see-tar
  dix diy dax day dljx dljy dnx dny       ;; direction vectors
  counted
  value
  consume
  first-to-detect
  vulture-in-view

]

sheep-own [
 energy
]

;;create output file
to setup
  clear-all
  reset-ticks
;  let file user-new-file
;  if is-string? file
;  [
;    if file-exists? file
;      [ file-delete file ]
;    file-open file
;    write-to-file
;  ]

  ;; Colors and sizes
  set color-bkg                  black
  set color-tar                  yellow
  set color-descend              red
  set color-vulture              white
  set color-user                 green
  set size-of-agent              4
  set size-of-map                area-slider
  set size-of-patch              3 * 100 / size-of-map
  resize-world (-1 * size-of-map) size-of-map (-1 * size-of-map) size-of-map
  set-patch-size size-of-patch

  ;; Hyperparameters
  let start-dist              20
  set population              10
  set vision-food             15
  set vision                  1.5 * vision-food
  set eating-dist             1
  set vulture-gain            1
  set cohesion-dist           vision * 1.5
  set turn-angle              180
  set hp-tar                  500
  set hp-current              500
  set reset-tar               false
  set vultures-descending     false

  ;; LJP Params
  set R                       0.8 * vision
  set ljp-alpha               4
  set ljp-beta                3
  set ljp-well-depth          0.5
  set sij-lim                 10

  ;; Direction parameters
  set alpha                   0.5;alpha-slider
  set epsilon                 0.5;epsilon-slider
  set gamma                   0.5;gamma-slider

  ;; Turtle parameters
  set mov-spd                 1

  ;; Simulation settings
  set mouse-always-down       true
  set users-on                true
  set smoothing-on            false
  set cohesion-on             true
  set alignment-on            true
  set tic-max                 13500

  set group-eff                    0
  set user-eff                     0
  set eff-scale                    1000
  set t2d-start                    0
  set t2d-on                       true
  set t2e-start                    0
  set t2e-on                       false
  set t2d                          0
  set t2e                          0
  set user-t2d-start               0
  set user-t2d-on                  true
  set user-t2d                     0
  set user-t2e-start               0
  set user-t2e-on                  false
  set user-t2e                     0
  set avg-t2d                      tic-max
  set avg-t2e                      hp-tar
  set user-avg-t2d                 tic-max
  set user-avg-t2e                 hp-tar
  set tar-count                    0
  set tar-count-end                0
  set tic-int-count                0
  set tic-eat-user                 0
  set len                          0
  set tot-len                      0

  ;======for testing===============
  ifelse cohesion?
  [set cohesion-on true]
  [set cohesion-on false]

  ifelse alignment?
  [set alignment-on true]
  [set alignment-on false]

  ifelse users?
  [ set users-on true ]
  [ set users-on false ]
  ;================================

  ;; Initialize Simulation
  ask patches [
   set pcolor color-bkg
  ]

  if users-on = true
  [
    set population             population - 1
    create-user 1
    [ set color color-user
      set size size-of-agent
      setxy random start-dist random start-dist
      set flockmates no-turtles
      set descending false
      set see-tar false
      set feasting false
      set dax 0
      set day 0
      set dljx 0
      set dljy 0
      set dnx 0
      set dny 0
      set dix random-float 1
      set diy random-float 1
      set old-heading heading
      set vulture-in-view 0
    ]
   create-vision-boundary 1 [
   set shape                      "circle 3"
   set color                       color-user
   set size                        vision * size-of-patch * 0.8
   setxy xcor-user ycor-user
  ]
    ask user [ update-vision-boundary ]
  ]

  create-vultures population
  [
    set color color-vulture
    set size size-of-agent
    setxy random start-dist random start-dist
    set flockmates no-turtles
    set descending false
    set feasting false
    set see-tar false
    set dax 0
    set day 0
    set dljx 0
    set dljy 0
    set dnx 0
    set dny 0
    set dix random 1
    set diy random 1
    set old-heading heading
    set vulture-in-view 0
  ]

  create-sheep 1
  [
   set color color-tar
   set shape "star"
   set size size-of-agent
   set xcor-tar random-xcor
   set ycor-tar random-ycor
   setxy xcor-tar ycor-tar
   set energy hp-tar
  ]

  if users-on = true
  [ask vultures [ set color color-bkg ]
  ask sheep [ set color color-bkg]]
end

to go

  ;======for testing===============
  ifelse cohesion?
  [set cohesion-on true]
  [set cohesion-on false]

  ifelse alignment?
  [set alignment-on true]
  [set alignment-on false]

  ifelse users?
  [ set users-on true ]
  [ set users-on false ]

  set alpha                   alpha-slider
  set epsilon                 epsilon-slider
  set gamma                   gamma-slider
  ;================================

  set len 0

  ask vultures [
    find-food
    if descending = false
    [update-direction]]

  if users-on = true [
    ask user [
    find-food
    if feasting = true
    [set tic-eat-user tic-eat-user + 1]
    if descending = false
    [update-direction
     set user-head heading]
    update-vision-boundary
    ]]

  ifelse smoothing-on = true
  [
    repeat 5 [
    ask vultures [
    ifelse feasting = true
    [ setxy xcor-tar ycor-tar
      set heading-change 0]
    [fd mov-spd / 5
     set len len + 1 / 5] ]
     ask user [
     ifelse feasting = true
     [setxy xcor-tar ycor-tar
        set heading-change 0]
     [fd mov-spd / 5
      set len len + 1 / 5]]
   display ]
  ]
  [
    ask vultures [
    ifelse feasting = true
    [ setxy xcor-tar ycor-tar
      set heading-change 0 ]
    [fd mov-spd
     set len len + 1] ]
     ask user [
     ifelse feasting = true
     [setxy xcor-tar ycor-tar
      set heading-change 0]
     [fd mov-spd
      set len len + 1]]
  ]

  ifelse users-on = true
  [ update-fog ]
  [ clear-fog
    ask user [
      find-food
    if feasting = true
    [set tic-eat-user tic-eat-user + 1]
    if descending = false
    [update-direction
     set user-head heading]
    update-vision-boundary ]]


  set tot-len tot-len + len

  ; update effciency
  set group-eff (eff-scale * tar-count / tot-len )
  set user-eff (eff-scale * user-eat-count / tot-len )

  tick
  if ticks > tic-max
  [stop]

  ;write-to-file
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;               FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to update-vision-boundary
  set xcor-user [xcor] of self
  set ycor-user [ycor] of self
  ask vision-boundary
  [
    setxy xcor-user ycor-user
  ]
end


to clear-fog
  ask vultures
  [
    ifelse descending = true
    [set color color-descend]
    [set color color-vulture]
  ]
  ask sheep [ set color color-tar]
end

to update-fog
  ask turtles [ set counted false ]
  ask vultures [ set color color-bkg ]
  ask sheep [ set color color-bkg]
  ask user
  [
  let vultures-in-view vultures in-radius vision
    if any? vultures-in-view [
      ask vultures-in-view [
        ifelse descending = true
        [set color color-descend
         set vultures-descending true
         set counted true]
        [set color color-vulture
         set vultures-descending false]
        uncover-fog-vultures]
  ]

  let sheep-in-view sheep in-radius vision-food
  ask sheep-in-view [
    set color color-tar
    set counted true
  ]
  ]
end

to uncover-fog-vultures
  while [vultures-descending = true]
  [
    let vultures-in-view vultures in-radius vision with [descending and not counted]
    ifelse any? vultures-in-view
    [
      ask vultures-in-view
      [ set color color-descend
        set counted true
        let sheep-in-view sheep in-radius vision-food with [not counted]
        ask sheep-in-view
        [ set color color-tar
          set counted true ]
      ]
    ]
    [
      set vultures-descending false
    ]
  ]
end

to find-food
  find-sheep
  ifelse any? nearby-sheep
  [
    set descending true
    set see-tar true
    set following false
    if ((count(vultures in-radius vision) = 0) and see-tar = true) [ set alone true ]
    if feasting = true [
      set alone false
      set consume consume + 1 ]
    find-nearest-sheep
    face nearest-sheep
    eat-sheep
  ]
  [
    find-wake
    ifelse any? wake
    [
      find-nearest-neighbor
      ifelse [see-tar] of nearest-neighbor
      [set descending true
       face nearest-neighbor]
      [set descending false
      set see-tar false
      set following true]
    ]
    [
      set descending false
      set see-tar false
      set following false
      set alone false
    ]
    find-wake-user
    ifelse any? wake
    [
      find-nearest-neighbor
      ifelse [see-tar] of nearest-neighbor
      [set descending true
       face nearest-neighbor]
      [set descending false
      set see-tar false
      set following true]
    ]
    [
      set descending false
      set see-tar false
      set following false
    ]
  ]
end

to find-sheep
  set nearby-sheep sheep in-radius vision-food
end

to find-nearest-sheep
  set nearest-sheep min-one-of nearby-sheep [distance myself]
end

to find-wake  ;; vulture procedure
  set wake vultures in-radius vision with [descending]
end

to find-wake-user  ;; vulture procedure
  set wake user in-radius vision with [descending]
end

to find-nearest-neighbor ;; vulture procedure
  set nearest-neighbor min-one-of wake [distance myself]
end

to eat-sheep
  let prey sheep in-radius eating-dist
  if any? prey
  [
    if user-t2d-on = true
    [
      ask user
      [
        if feasting = true
        [
      set user-t2d ticks - user-t2d-start
      set user-t2e-start ticks
      set user-t2d-on false
      set user-eat-count user-eat-count + 1
      ifelse user-eat-count = 1
      [ set user-avg-t2d user-t2d ]
      [ set user-avg-t2d (user-avg-t2d + user-t2d) / 2 ]
        ]
      ]
    ]

    if t2d-on = true
    [
      set t2d ticks - t2d-start
      set t2e-start ticks
      set t2d-on false
      set tar-count tar-count + 1
      if t2d-on = false or user-t2d-on = false [ set first-to-detect first-to-detect + 1 ]
      ifelse tar-count = 1
      [ set avg-t2d t2d ]
      [ set avg-t2d (avg-t2d + t2d) / 2]
    ]
    set feasting true
    set descending false
    ask prey
    [
      set energy energy - vulture-gain
      set hp-current energy - vulture-gain
      if energy < 0
      [
        set reset-tar true
        set hp-current 500
        set tar-count-end tar-count-end + 1
        hatch 1
        [
          set energy hp-tar
          set xcor-tar random-xcor
          set ycor-tar random-ycor
          setxy xcor-tar ycor-tar
        ]
        die
      ]
    ]
    if (reset-tar = true)
    [
        set reset-tar false
        reset-vulture-feasting
    ]
 ]
end

to update-direction  ;; procedure to update new direction
  set dax 0
  set day 0
  set dljx 0
  set dljy 0
  set old-heading heading

  let numvulture count turtles in-radius vision
  set vulture-in-view (vulture-in-view + numvulture) / 2

  update-da
  update-dlj
  update-dn

  set dix (alpha * dax + epsilon * dljx + gamma * dnx)
  set diy (alpha * day + epsilon * dljy + gamma * dny)
  set heading (atan dix diy)

  get-heading-change
end

to get-heading-change
  ifelse old-heading = heading
  [
    set heading-change 0
    if breed = user
    [set user-heading-change 0]
  ]
  [
  let xi sin old-heading
  let yi cos old-heading
  let xf sin heading
  let yf cos heading
  let rhs ( (xi * xf + yi * yf) / (sqrt (xi ^ 2 + yi ^ 2) * sqrt (xf ^ 2 + yf ^ 2) ) )
  if rhs > 1
    [set rhs 1]
  if rhs < -1
    [set rhs -1]
  set heading-change  acos rhs
  if breed = user
    [set user-heading-change heading-change]
  ]
end

to update-da   ;; alignment mechanism
  if alignment-on = true
  [
  find-flockmates
  ifelse any? flockmates
  [ set dax sum [dx] of flockmates
    set day sum [dy] of flockmates ]
    [ set dax sin [heading] of self
      set day cos [heading] of self ]
  ]
end

to update-dlj   ;; cohesion mechanism
  if cohesion-on = true
  [
    set tempx 0
    set tempy 0
    if breed = user
    [
     find-cohesionmates-vultures
     update-dlj-subroutine
    ]
    if breed = vultures [
    find-cohesionmates
    update-dlj-subroutine
    find-cohesionmates-user
    update-dlj-subroutine
    ]
  ]
end

to update-dlj-subroutine
    if any? cohesionmates
    [
      ;; get heading of current agent i
      let xi [xcor] of self
      let yi [ycor] of self

      ask cohesionmates
      [
        ;; get info on agent j
        let xj [xcor] of self
        let yj [ycor] of self
        let sij distancexy xi yi
        let sheading random 360
        if (yj - yi) = 0 and (xj - xi) = 0
        [set yj yj + random-float 10 - random-float 10
        set xj xj + random-float 10 - random-float 10]
        set sheading atan (xj - xi) (yj - yi)
        ;set sheading towardsxy (xj - xi) (yj - yi)
        if sij <= sij-lim
        [ set sij sij-lim ]
        let f ( (R / sij) ^ ljp-alpha - (R / sij) ^ ljp-beta )
        set tempx tempx - f * sin ( sheading )
        set tempy tempy - f * cos ( sheading )
      ]

      set dljx ljp-well-depth * tempx
      set dljy ljp-well-depth * tempy
    ]
end

to update-dn   ;; noise / user input
  if breed = vultures
  [
    let dn heading + random turn-angle - random turn-angle ; correlated random walk
    set dnx sin dn
    set dny cos dn
  ]
  if breed = user
  [
    ifelse mouse-down? or mouse-always-down = true
    [ set tic-int-count tic-int-count + 1
      let xcom mouse-xcor
      let ycom mouse-ycor
      ;let normxy sqrt (xcom ^ 2 + ycom ^ 2)
      set dnx xcom ;/ normxy
      set dny ycom ;/ normxy
    ]
    [ let dn heading + random turn-angle - random turn-angle
      set dnx sin dn
      set dny cos dn ]
  ]
end

to find-flockmates  ;; turtle procedure
  set flockmates other turtles in-radius vision
end

to find-cohesionmates ;; turtle procedure
  set cohesionmates other vultures in-radius cohesion-dist
end

to find-cohesionmates-vultures ;; turtle procedure
  set cohesionmates vultures in-radius cohesion-dist
end

to find-cohesionmates-user ;; turtle procedure
  set cohesionmates user in-radius cohesion-dist
end

to reset-vulture-feasting
  ask vultures
  [
    set feasting false
    set descending false
    set see-tar false
  ]

  ask user
  [
    set feasting false
    set descending false
    set see-tar false
  ]

  set t2d-on true
  set t2d-start ticks
  set t2e ticks - t2e-start
  ifelse tar-count = 1
  [ set avg-t2e t2e]
  [ set avg-t2e (avg-t2e + t2e) / 2]

  set user-t2d-on true
  set user-t2d-start ticks
  set user-t2e ticks - user-t2e-start
  ifelse user-eat-count = 1
  [ set user-avg-t2e user-t2e]
  [ set user-avg-t2e (user-avg-t2e + user-t2e) / 2]

end

to write-to-file
  output-print (ticks)
  foreach list user vultures [ t ->
    ask t
    [
      if users-on = true
      [
      file-print (word self "," ticks
          "," xcor ; vulture and user x position
          "," ycor ; vulture and user y position
          "," xcor-tar ; target x position
          "," ycor-tar ; target y position
          "," tar-count ; vulture targets found count
          "," user-eat-count ; user's targets found count
          "," first-to-detect ; first to detect new target count
          "," hp-current ; how many hit-points does the target has currently? 0-500
          "," alone ; can see the food but no other vultures? T or F
          "," following ; can see others descending? T or F
          "," descending ; are they descending? T or F
          "," feasting ; are they currently eating? T or F
          "," consume ; (count(feasting) = true) ; how much has each vulture currenlty eaten?
          "," count(vultures in-radius vision) ; how many other vultures are in sight? 0-9
          "," heading-change) ; relative change in direction
      ]
    ]
  ]
  output-print " "
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@#$#@#$#@
GRAPHICS-WINDOW
474
25
1088
640
-1
-1
6.0
1
10
1
1
1
0
1
1
1
-50
50
-50
50
1
1
1
ticks
30.0

BUTTON
216
294
293
327
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
731
668
812
701
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SWITCH
302
278
411
311
cohesion?
cohesion?
0
1
-1000

SWITCH
302
311
411
344
alignment?
alignment?
0
1
-1000

SWITCH
1588
50
1691
83
users?
users?
1
1
-1000

MONITOR
1095
49
1152
94
targets
tar-count-end
17
1
11

SLIDER
1713
49
1885
82
alpha-slider
alpha-slider
0
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
1713
82
1885
115
epsilon-slider
epsilon-slider
0
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
1687
103
1859
136
gamma-slider
gamma-slider
0
1
0.5
0.05
1
NIL
HORIZONTAL

TEXTBOX
1173
182
2108
341
NIL
11
0.0
0

BUTTON
1168
577
1246
611
NIL
file-close
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
250
226
422
259
area-slider
area-slider
50
500
50.0
50
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model is an attempt to mimic the flocking of birds.  (The resulting motion also resembles schools of fish.)  The flocks that appear in this model are not created or led in any way by special leader birds.  Rather, each bird is following exactly the same set of rules, from which flocks emerge.

## HOW IT WORKS

The birds follow three rules: "alignment", "separation", and "cohesion".

"Alignment" means that a bird tends to turn so that it is moving in the same direction that nearby birds are moving.

"Separation" means that a bird will turn to avoid another bird which gets too close.

"Cohesion" means that a bird will move towards other nearby birds (unless another bird is too close).

When two birds are too close, the "separation" rule overrides the other two, which are deactivated until the minimum separation is achieved.

The three rules affect only the bird's heading.  Each bird always moves forward at the same constant speed.

## HOW TO USE IT

First, determine the number of birds you want in the simulation and set the POPULATION slider to that value.  Press SETUP to create the birds, and press GO to have them start flying around.

The default settings for the sliders will produce reasonably good flocking behavior.  However, you can play with them to get variations:

Three TURN-ANGLE sliders control the maximum angle a bird can turn as a result of each rule.

VISION is the distance that each bird can see 360 degrees around it.

## THINGS TO NOTICE

Central to the model is the observation that flocks form without a leader.

There are no random numbers used in this model, except to position the birds initially.  The fluid, lifelike behavior of the birds is produced entirely by deterministic rules.

Also, notice that each flock is dynamic.  A flock, once together, is not guaranteed to keep all of its members.  Why do you think this is?

After running the model for a while, all of the birds have approximately the same heading.  Why?

Sometimes a bird breaks away from its flock.  How does this happen?  You may need to slow down the model or run it step by step in order to observe this phenomenon.

## THINGS TO TRY

Play with the sliders to see if you can get tighter flocks, looser flocks, fewer flocks, more flocks, more or less splitting and joining of flocks, more or less rearranging of birds within flocks, etc.

You can turn off a rule entirely by setting that rule's angle slider to zero.  Is one rule by itself enough to produce at least some flocking?  What about two rules?  What's missing from the resulting behavior when you leave out each rule?

Will running the model for a long time produce a static flock?  Or will the birds never settle down to an unchanging formation?  Remember, there are no random numbers used in this model.

## EXTENDING THE MODEL

Currently the birds can "see" all around them.  What happens if birds can only see in front of them?  The `in-cone` primitive can be used for this.

Is there some way to get V-shaped flocks, like migrating geese?

What happens if you put walls around the edges of the world that the birds can't fly into?

Can you get the birds to fly around obstacles in the middle of the world?

What would happen if you gave the birds different velocities?  For example, you could make birds that are not near other birds fly faster to catch up to the flock.  Or, you could simulate the diminished air resistance that birds experience when flying together by making them fly faster when in a group.

Are there other interesting ways you can make the birds different from each other?  There could be random variation in the population, or you could have distinct "species" of bird.

## NETLOGO FEATURES

Notice the need for the `subtract-headings` primitive and special procedure for averaging groups of headings.  Just subtracting the numbers, or averaging the numbers, doesn't give you the results you'd expect, because of the discontinuity where headings wrap back to 0 once they reach 360.

## RELATED MODELS

* Moths
* Flocking Vee Formation
* Flocking - Alternative Visualizations

## CREDITS AND REFERENCES

This model is inspired by the Boids simulation invented by Craig Reynolds.  The algorithm we use here is roughly similar to the original Boids algorithm, but it is not the same.  The exact details of the algorithm tend not to matter very much -- as long as you have alignment, separation, and cohesion, you will usually get flocking behavior resembling that produced by Reynolds' original model.  Information on Boids is available at http://www.red3d.com/cwr/boids/.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1998).  NetLogo Flocking model.  http://ccl.northwestern.edu/netlogo/models/Flocking.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1998 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2002.

<!-- 1998 2002 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

circle 3
false
0
Circle -7500403 false true 8 8 283

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
set population 200
setup
repeat 200 [ go ]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="gamma-slider">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-slider">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cohesion?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="users?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alignment?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="epsilon-slider">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cf_area_batch" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>tar-count</metric>
    <metric>avg-t2d</metric>
    <metric>avg-t2e</metric>
    <metric>[consume] of turtles</metric>
    <metric>[first-to-detect] of turtles</metric>
    <metric>[vulture-in-view] of turtles</metric>
    <enumeratedValueSet variable="cohesion?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alignment?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="users?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="area-slider">
      <value value="50"/>
      <value value="50"/>
      <value value="500"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cf_sim_coh_off_align_off" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>tar-count</metric>
    <metric>avg-t2d</metric>
    <metric>avg-t2e</metric>
    <metric>[consume] of turtles</metric>
    <metric>[first-to-detect] of turtles</metric>
    <metric>[vulture-in-view] of turtles</metric>
    <enumeratedValueSet variable="gamma-slider">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-slider">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cohesion?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="users?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alignment?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="epsilon-slider">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cf_sim_coh_off_align_on" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>tar-count</metric>
    <metric>avg-t2d</metric>
    <metric>avg-t2e</metric>
    <metric>[consume] of turtles</metric>
    <metric>[first-to-detect] of turtles</metric>
    <metric>[vulture-in-view] of turtles</metric>
    <enumeratedValueSet variable="gamma-slider">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-slider">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cohesion?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="users?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alignment?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="epsilon-slider">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cf_area_150" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>tar-count</metric>
    <metric>avg-t2d</metric>
    <metric>avg-t2e</metric>
    <metric>[consume] of turtles</metric>
    <metric>[first-to-detect] of turtles</metric>
    <metric>[vulture-in-view] of turtles</metric>
    <enumeratedValueSet variable="cohesion?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alignment?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="users?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
