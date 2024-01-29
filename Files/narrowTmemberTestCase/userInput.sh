#!/bin/bash
 #----------------------------------------------------------------------------#
#|                                 User Inputs                                |#
 #----------------------------------------------------------------------------#

 #----------------------------------------#
#|        Choose mesh and model           |#
 #----------------------------------------#
# Available meshType choices are:
# hex
# tet

meshType="
tet
"

# Available Solid Models are:
# unsLinearGeometry
# linearGeometryTotalDisplacement
# linearGeometry
# coupledUnsLinearGeometryLinearElastic
# coupledStabilised

models="
coupledUnsLinearGeometryLinearElastic
coupledStabilised
"

 #----------------------------------------#
#|              Case settings             |#
 #----------------------------------------#
latestTime="1"
 #----------------------------------------#
#|           Sampling settings            |#
 #----------------------------------------#
INTERPSCHEME="
cellPointFace
"
# Possible choices are:
# cell
# cellPoint
# cellPointFace

FIELDS="\n\
sigmaxx\n\
sigmayy\n\
sigmazz\n\
sigmaxy\n\
sigmaxz\n\
sigmayz\n\
"

TYPE="
midPoint
"
# Possible choices are:
# midPoint
# unifrom
# face
# midPointAndFace

AXIS="
x
"
# Possible choices are:
# x
# y
# z
# distance

START="(-.11 .026 .007)"
END="(.051 .026 .007)"
NPOINTS="5000"
