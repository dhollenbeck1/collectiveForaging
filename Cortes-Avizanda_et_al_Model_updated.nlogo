;-----------------------------------------------------------------------------------------------------------------
;
; This program was developed using NetLogo 5.0.3 (http://ccl.northwestern.edu/netlogo)
; by Roger Jovani, Ainara Cortés-Avizanda and Volker Grimm in Leipzig (Germany), 2011 and Sevilla (Spain), 2012
;
; It implements the model described in:
;
;   Cortés-Avizanda, A., Jovani, R., Donázar, J.A., Grimm, V. 2013.
;        Bird sky networks:how do avian scavengers use social information to find carrion? Ecology
;
; The program is free of use for research and education. If you use this program or model
; for your own research, please refer to our paper as described above.
;
; Copyright: Roger Jovani, Ainara Cortes-Avizanda and Volker Grimm, Sevilla 2012
; To run the model change file extension from “.txt” to “.nlogo” before open it with NetLogo.;;


;-----------------------------------------------------------------------------------------------------------------

;carcasses:
breed [ carcasses carcass ]

;states of vultures:
breed [ searchers searcher ]  ; A vulture without personal nor social information about carcass location.
breed [ finders finder ]      ; A vulture that has either seen a carcass (or vultures feeding on a carcass). In the 'local enhancement' submodel, also vultures that have seen other ;vultures sinking to a carcass.
breed [ followers follower ]  ; In the 'chain of vultures' submodel, a vulture that is following other vultures belonging to a chain of vultures.
breed [ feeders feeder ]      ; A vulture that has already arrived to the carcass.

;carcass variables:
carcasses-own  [ radius ]

;vulture variables:
finders-own    [ my-carcass sinking-to-carcass? ]
followers-own  [ my-leader ]
feeders-own    [ my-carcass ]

globals
  [ step-length ]        ; how many cells a vulture progress in a time step of the model (see 'Setup' below)

;========================== Initialise =====================================
to setup
  clear-all
  if Default-Parameters = true    [ set-Default-Parameters ] ;this disable slides and use default parameters (Table 2 of the associated paper).
  if Uncertainty-Analysis = true  [ set-Uncertainty-Analysis-Parameters ] ; this runs an uncertainty analysis (Table 2 of the associated paper). Variables' definitions as above
  if enhance-visualization = true [ ask patches [ set pcolor white ] ]
  create-searchers Nvul
    [ setxy random-xcor random-ycor      ; all vultures start as searchers in a random position
      if enhance-visualization = true [ hide-turtle   set color 9   pd ]
  ]
  create-carcasses Ncar
    [ setxy random-xcor random-ycor      ; carcasses start distributed at random on the lattice
      set radius Dunocc                  ; carcasses start unoccupied
      if enhance-visualization = true
    [
      set color black
      set size 1
      set shape "circle"
    ]
  ]
  set step-length (Fs / 360)  ; how many cells (of 1x1 km) a vulture progress in a time step of the model (of 10 seconds)
  reset-ticks
end

to set-Default-Parameters
  resize-world 0 99 0 99 ; Lattice size of 100x100km
  set-patch-size 7       ; Visualization purposes
  set Fh 5               ; 'Foraging hours'. Hours simulated. A foraging day.
  set Fs 45              ; 'Foraging speed'. In km/h. (1 space unit in the model simulates 1Km)
  set Ncar 30            ; 'Number of carcasses'
  set Nvul 2900          ; 'Number of vultures'
  set Dunocc 0.3         ; 'Distance unoccupied'. Distance at which a vulture can see an unoccupied carcass.
  set Docc 4             ; 'Distance occupied'. Distance at which a vulture can see an occupied carcass.
  set Dland-foll 7       ; 'Distance landing-following': - In 'local enhancement' submodel: Dland is the distance at which a vulture detects a vulture is descending in vertical flight towards a carcass.
                         ;                               - In 'chain of vultures' submodel: Dfoll is the distance at which a vulture detects a vulture belonging to a chain of vultures.
end

to set-Uncertainty-Analysis-Parameters
  resize-world 0 99 0 99
  set-patch-size 7
  set Fh random-normal 5 1
  set Fs random-normal 45 5
  set Ncar ceiling random-normal 30 5
  set Nvul ceiling  random-normal 2900 100
  set Dunocc random-normal 0.3 0.05
  set Docc random-normal 4 0.5
  set Dland-foll Docc * 1.75
end

;================================ Start simulation =====================================
to go
  if SubModel = "non-social"         [ non-social-submodel ]
  if SubModel = "local enhancement"  [ local-enhancement-submodel ]
  if SubModel = "chains of vultures" [ chains-of-vultures-submodel ]
  if ticks > Fh * 360    ; time steps are modeled as lasting for 10 second; i.e. one simulation lasts Fh * 360 time steps of the model
    [ if Default-Parameters = true and export_output = true
        [ output-default-parameters ]
      if Uncertainty-Analysis = true and export_output = true
        [ output-UA ]
      stop ]
  tick
end

;----------------------------- 'non-social' SubModel ------------------------------------
;
; Note: In reality vultures check for carcasses within their detection radius.
;       In the program, however, we make, for computational efficiency, the carcasses
;       look for vultures within the detection radius. This "ask carcasses" construct
;       is included in both social submodels, but the the "chain-of-vultures" submodel
;       also has to include "ask searchers", i.e. all searchers check for finders and
;       followers within their detection radius.

to non-social-submodel
  ask carcasses
    [ if any? finders in-radius step-length
      [ ask finders in-radius step-length
        [ set my-carcass myself            ; this is necessary because the finder could (unlikely) have a different my-carcass than the one calling it.
          set sinking-to-carcass? true ] ]
      if any? searchers in-radius radius
        [ ask searchers in-radius radius
          [ if enhance-visualization = true [ set color sky ]
            set breed finders
            set my-carcass myself
            face my-carcass  ] ]
      if enhance-visualization = true [ set size 1 ] ]
  move
end

;----------------------- 'local enhancement' SubModel -----------------------------------
to local-enhancement-submodel
  ask carcasses
    [ if any? finders in-radius step-length  ; this ensures that no finder (i.e. a vulture that already knows carcass location) overlooks the carcass during the next minute
        [ ask finders in-radius step-length
          [ set my-carcass myself            ; this is necessary because the finder could (unlikely) have a different my-carcass than the one calling it.
            set sinking-to-carcass? true ] ]
      if any? searchers in-radius radius
        [ ask searchers in-radius radius
          [ set breed finders
            if enhance-visualization = true [ set color sky ]
            set my-carcass myself
            face my-carcass ] ]
      if enhance-visualization = true [ set size 1 ] ]
  move
end

;------------------------- 'chains of vultures' SubModel ------------------------------------
to chains-of-vultures-submodel
  ask carcasses
    [ if any? finders in-radius step-length
      [ ask finders in-radius step-length
        [ set my-carcass myself              ; this is necessary because the finder could (unlikely) have a different my-carcass than the one calling it.
          set sinking-to-carcass? true ] ]   ; in this way, in the next time step the finder will arrive to the carcass.
      if any? turtles with [ breed = searchers OR breed = followers ] in-radius radius
        [ ask turtles with [ breed = searchers OR breed = followers ] in-radius radius
          [ if enhance-visualization = true [ set color color - 0.01 ]
            set breed finders
            set my-carcass myself
            face my-carcass ] ]
      if enhance-visualization = true [ set size 1 ] ]
  ask searchers
    [ ifelse any? finders in-radius Dland-foll
      [ set breed followers
        if enhance-visualization = true [ set color sky ]
        set my-leader one-of finders in-radius Dland-foll ]
      [ if any? followers in-radius Dland-foll
        [ if enhance-visualization = true [ set color sky ]
          set breed followers
          set my-leader one-of other followers in-radius Dland-foll ] ] ]
  move
end

;------------------------------ common to the three submodels -------------------------------
to move
  ask finders
    [ ifelse sinking-to-carcass? = true
      [ move-to my-carcass
        if SubModel = "local enhancement" OR submodel = "chains of vultures"
          [ ask my-carcass
            [ set radius Docc ] ]
        if SubModel = "local enhancement"
          [ if any? searchers in-radius Dland-foll
            [ ask searchers in-radius Dland-foll
              [ set breed finders
                if enhance-visualization = true [ set color sky ]
                set my-carcass [ my-carcass ] of myself
                face my-carcass ] ] ]
        set breed feeders ]
      [ fd step-length ] ]
  ask searchers
    [ if enhance-visualization = true [ set color color - 0.003 ]
      fd step-length
      if random-float 1 < ( 1 / 360 ) ;searchers change flight direction once every hour, on average.
        [ ifelse random 2 = 0
          [ rt 45 ]
          [ lt 45 ] ] ]
  ask followers
    [ if enhance-visualization = true [ set color color - 0.007 ]
      face my-leader
      fd step-length ]
end

;=================================== OUTPUT generator =======================================
to output-UA
;   let occupied-carcasses carcasses with [ count feeders with [ my-carcass = myself ] > 0 ]
;   file-open "UncertaintyAnalysis.txt"
;       file-write SUBMODEL
;       file-write Ncar
;       file-write Nvul
;       file-write Dland-foll
;       ;; only occupied carcasses are considered to calculate the statistics
;       file-write min    [ count feeders with [ my-carcass = myself ] ] of occupied-carcasses
;       file-write median [ count feeders with [ my-carcass = myself ] ] of occupied-carcasses
;       file-write mean   [ count feeders with [ my-carcass = myself ] ] of occupied-carcasses
;       file-write max    [ count feeders with [ my-carcass = myself ] ] of occupied-carcasses
;       file-print ""
;       ask carcasses    ;; all carcasses (occupied or not) report their number of feeders.
;          [ file-write SubModel
;            file-write Ncar
;            file-write Nvul
;            file-write Dland-foll
;            file-write count feeders with [ my-carcass = myself ]
;            file-print "" ]
;   file-close
end

to output-default-parameters
;   let occupied-carcasses carcasses with [ count feeders with [ my-carcass = myself ] > 0 ]
;   file-open "submodel-with-default-parameters.txt"
;       file-write SubModel
;       file-write min    [ count feeders with [ my-carcass = myself ] ] of occupied-carcasses
;       file-write median [ count feeders with [ my-carcass = myself ] ] of occupied-carcasses
;       file-write mean   [ count feeders with [ my-carcass = myself ] ] of occupied-carcasses
;       file-write max    [ count feeders with [ my-carcass = myself ] ] of occupied-carcasses
;       file-print ""
;   ask carcasses
;     [ file-write SubModel
;       file-write count feeders with [ my-carcass = myself ]
;       file-print "" ]
;   file-close
end
@#$#@#$#@
GRAPHICS-WINDOW
233
12
941
721
-1
-1
7.0
1
10
1
1
1
0
1
1
1
0
99
0
99
1
1
1
ticks
30.0

BUTTON
14
10
77
43
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
83
11
203
44
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
1

SLIDER
18
324
177
357
Nvul
Nvul
1
4350
2900.0
1
1
vultures
HORIZONTAL

CHOOSER
16
128
205
173
SubModel
SubModel
"non-social" "local enhancement" "chains of vultures"
2

SLIDER
18
360
176
393
Ncar
Ncar
0
50
30.0
1
1
carcasses
HORIZONTAL

SLIDER
20
595
202
628
Dland-foll
Dland-foll
0
10
7.0
0.1
1
km
HORIZONTAL

SLIDER
19
521
203
554
Dunocc
Dunocc
0
2
0.3
0.1
1
km
HORIZONTAL

SLIDER
19
557
202
590
Docc
Docc
0
10
4.0
1
1
km
HORIZONTAL

SWITCH
16
181
206
214
Default-Parameters
Default-Parameters
0
1
-1000

SWITCH
954
341
1144
374
Uncertainty-Analysis
Uncertainty-Analysis
1
1
-1000

TEXTBOX
955
297
1143
354
Set these switches 'Off' if you only want to \"play\" with the model.
12
0.0
1

SLIDER
18
420
177
453
Fh
Fh
0
10
5.0
1
1
hours
HORIZONTAL

SLIDER
18
459
201
492
Fs
Fs
0
100
45.0
1
1
km/h
HORIZONTAL

TEXTBOX
20
231
217
311
With \"Default-Parameters\"=\"On\" slides below become disabled; \ni.e. set \"Default-Parameters\"=\"Off\" to use slides below.
12
0.0
1

SWITCH
955
380
1144
413
export_output
export_output
1
1
-1000

SWITCH
952
64
1145
97
enhance-visualization
enhance-visualization
1
1
-1000

TEXTBOX
22
637
226
685
(see the definition of variables in the \n\"code\" tab under \"globals\")\n
12
0.0
1

TEXTBOX
954
285
1143
303
-----------------------------------------------
12
0.0
1

TEXTBOX
957
416
1160
448
-----------------------------------------------
12
0.0
1

TEXTBOX
14
50
204
114
TO RUN THE SIMULATION:\nSelect the desired \"SubModel\".\nThen press \"setup\" and then \"go\".
12
0.0
1

TEXTBOX
956
104
1210
200
VISUALIZATION:\nBlack dots: carcasses.\nGrey lines: the paths of searchers.\nBlue lines: the paths of finders and followers.\n
12
0.0
1

@#$#@#$#@
# Model description

The model description following the ODD (Overview, Design concepts and Details) protocol for describing individual- and agent-based models (Grimm & Railsback 2005; Grimm et al. 2006, 2010).

## ## PURPOSE 

The purpose of the model is to confront three alternative hypotheses on how griffon vultures use personal and social information to find carcasses. The model could be parametrised with real data on vulture and carcass density as well as real study area in order to compare model output with empirical data on the number of vultures attending experimental carcasses in the field. This is what was done in the paper: Cortés-Avizanda, A., Jovani, R., Donázar, J.A., Grimm, V. 201X. Bird sky networks: how do vultures find carcasses? Journal XXX: XXX-XXX. 

## ## STATE VARIABLES AND SCALES

The entities of the model are carcasses and vultures. A carcass is characterized by its coordinates and status: unoccupied or occupied by vulture(s). A vulture is characterized by its coordinates and status, which can be searcher, finder, follower, or feeder (Table 1-Definitions in the main text). Simulations are run on a 100×100 square grid of 1km2 cells (i.e. 10,000 km2), which corresponds to the extension of the study area (see Material and Methods in the main text). Edge effects are avoided by applying periodic boundary conditions, i.e. the grid is a torus. This is done because our study area is not a closed population of griffon vultures. Periodic boundaries allow simulating a constant population size in the study area while allowing the constant flow of birds through the area. One time step of the model corresponds to 10 seconds; simulations last for one foraging day with Fh number of hours (i.e. Fh/60 time steps).

## ## PROCESS OVERVIEW AND SCHEDULING

At every time step, the position, direction of flight and state of each (non-feeding) vulture is updated in random order. Depending on the submodel, vultures search directly for carcasses and indirectly via cues from conspecific (see below). Then, they move to a new position according to the information just gathered, and their direction and flight speed (Fs). If no information is gathered (no carcass and no social cue) they move following a random path that is shared by the three submodels (following Jackson et al. 2008): each time step of the model, searchers decide whether to change their direction or to keep the previous flight direction. On average, searchers change direction once per hour, i.e. every time step, vultures have a probability of 1/360 to turn. When they decide to change direction, they do so with equal probability either right or left by 45º. In all submodels, once a searcher (or a follower) becomes a finder (either by seeing the carcass, the feeders on the carcass, or finders sinking vertically to the carcass) they fly in direct flight to the carcass, keeping their constant speed Fs. Also, in all submodels, once a finder arrives to a carcass it becomes a feeder and does not move for the rest of the simulation. Updating of vulture position and state as well as carcass state is asynchronous, carcasses and vultures are always processed in a sequence randomized anew each time step. Specific submodel details are explained below. 

## ## DESIGN CONCEPTS

Vultures are assumed to be able to _sense_ and respond adaptively to different personal and social information about carcass location. In the _'local enhancement'_ model it is assumed that vultures can identify the conspicuous cycling and eventual sinking of finders in vertical flight to the carcass. For the _'chains of vultures'_ submodel, it is assumed that vultures differentiate a searcher from a follower by their behaviour. Specifically, it is assumed that finders and followers gradually start losing altitude by dropping their feet, and that searchers note this behaviour and start following them (as detailed in Jackson et al. 2008 and Dermody et al. 2011; see electronic supplementary material C). Thus, chains of vultures _emerge_ from this behaviour depending on the local characteristics of vulture density and flight directions. It is assumed that vultures can detect other vultures and carcasses with 360º of vision. _Stochasticity_ is assumed for the initial spatial distribution of searchers and carcasses, and the random searching behaviour of searchers. To _observe_ the model output we calculated the number of feeders at the end of the simulation (at Fh) on each carcass with at least one feeder (as we did for experimental field carcasses).

## ## INITIALIZATION 

Simulations are initialized with _Ncar_ carcasses and _Nvul_ vultures randomly distributed on the lattice. All carcasses start as unoccupied, and all vultures as searchers heading at random initial directions. 

## ## INPUT

The model has not any external input, which means we assume the environment remains constant during the simulation.

## ## SUBMODELS

The behaviour of vultures differs between the threee different submodels (modeled hypotheses). See Figure 1 in the main text for a general overview of the different submodels. Submodel details:

### Non-social

Searchers can only see the carcass by themselves when closer to the carcass than _Dunocc_. Under this hypothesis, thus, the distance at which a searcher becomes a finder is always _Dunocc_, not changing to Docc when the first finder arrives to the carcass. 

### Local enhancement

Searchers become finders either by (1) seeing an unoccupied carcass by themselves at _Dunocc_, by (2) seeing feeders at an occupied carcass at _Docc_, or by (3) seeing a finder at _Dland_ that is landing to the carcass. This landing behaviour is assumed to last only during one time step of the model because this is a very fast flight (up to 144 km/h; Tucker 1988). Note that behaviour temporarily increases the distance at which other vultures can (indirectly) detect carcasses, i.e. the detection radius increases from _Docc_ (or from _Dunocc_ for the first finder landing to the carcass) to _Dland_. While this change is temporary, it can still lead to an information cascade if other vultures seeing the individual at _Dland_ go to the carcass and also signal the carcass. 		

### Chain of vultures

This is implemented as explained in Jackson et al. (2008) except for one detail to make the model simpler, and potentially also more realistic (see electronic supplemental material B under "changing leader"). In this submodel, searchers become finders either by (1) seeing an unoccupied carcass by themselves at _Dunocc_, or by (2) seeing feeders at an occupied carcass at _Docc_. Searchers become followers either by (1) seeing a finder at _Dfoll_ or by (2) seeing another follower at _Dfoll_. That means that when a searcher becomes a follower, this follower can be detected by other searchers (which become followers), triggering a social information cascade potentially leading vultures to eventually arrive to a carcass that they have initially not seen. Followers often create a chain, and eventually become finders when reaching a distance to a carcass of _Docc_ (note that this, by definition, cannot be _Dunocc_). 

# References

See the publication and/or the electonic supplementary material.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250
Rectangle -7500403 true true 120 225 120 255

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

vulture
true
0
Polygon -7500403 true true 150 0 135 300 150 210 165 300 150 0

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
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="3submodels-with-Default-Parameters" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="export_output">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Default-Parameters">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Uncertainty-Analysis">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SubModel">
      <value value="&quot;non-social&quot;"/>
      <value value="&quot;local enhancement&quot;"/>
      <value value="&quot;chains of vultures&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Uncertainty-Analysis" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="export_output">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Default-Parameters">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Uncertainty-Analysis">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SubModel">
      <value value="&quot;non-social&quot;"/>
      <value value="&quot;local enhancement&quot;"/>
      <value value="&quot;chains of vultures&quot;"/>
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
