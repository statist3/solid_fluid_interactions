#!/bin/bash
 #----------------------------------------------------------------------------#
#|                              Course of action                              |#
 #----------------------------------------------------------------------------#
# 1- Copy narrowTmember case from solids4Foam tutorial directory to the current
#    directory;
# 2- Copy the provided setSet.batch and createPatchDict files into the system;
# 3- Add these lines at the BEGINNING of boundary sub-dictionary of the file 0/D
#    "top.*"
#    {
#        type blockSolidTraction;
#        traction (0 0 0);
#        pressure 0;
#        value uniform (0 0 0);
#    }
# 4- bash Allrun.sh
# 
# Warnings:
# a- The demanded cases are removed if existing before the simulations start.
#

 #----------------------------------------------------------------------------#
#|                                 Processing                                 |#
 #----------------------------------------------------------------------------#

source userInput.sh
#bash userInput.sh

# Surface generation
clear
blockMesh -case narrowTmember
setSet -case narrowTmember -batch narrowTmember/system/setSet.batch
createPatch -overwrite -case narrowTmember
surfaceMeshTriangulate meshIntermediate.stl -case narrowTmember
#surfaceMeshTriangulate narrowTmember/meshIntermediate.stl -case narrowTmember
surfaceFeatureEdges -case narrowTmember narrowTmember/meshIntermediate.stl \
narrowTmember/mesh.stl

# Remove the existing cases (Only the cases that are selected will be removed)
for mesh in $meshType
do
    #for solProc in $solProcs
    #do
        for model in $models
	do
            caseDir="$mesh-$model"
	    rm -r $caseDir
	done
    #done
done

# Mesh generation and Pre-processing (D, solidProperties and fvSchemes)
for mesh in $meshType
do
    #for solProc in $solProcs
    #do
        for model in $models
	do
	    caseDir="$mesh-$model"
            echo "Copying narrowTmember to $caseDir"
            cp -r $(find . -maxdepth 1 -type d -name narrowTmember) \
                $caseDir
            mkdir $caseDir/sampling
            echo "Changing constant/solidProperties"
            sed -i s/MODEL/$model/g $caseDir/constant/solidProperties
            echo "Processing the case $caseDir"
            if [ "$model" = "unsLinearGeometry"  ]
            then
                echo "Changing 0/D"
                    sed -i s/blockS/s/g $caseDir/0/D
                    sed -i s/blockF/f/g $caseDir/0/D
                echo "Changing system/fvSchemes"
                sed -i s/gradSchemes/\
"gradSchemes\n\
{\n\
    \/\/default none;\n\
    default leastSquares;    \/\/ unsLinearGeometry\n\
    \/\/grad(D) extendedLeastSquares 0;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/divSchemes/\
"divSchemes\n\
{\n\
    default Gauss linear;    \/\/ unsLinearGeometry\n\
    \/\/default none;\n\
    \/\/div(sigma) Gauss linear;\n\
    \/\/div((impK*grad(D))) Gauss linear;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/laplacianSchemes/\
"laplacianSchemes\n\
{\n\
    default none;\n\
    laplacian(DD,D) Gauss linear corrected;\n\
    laplacian(DDD,DD) Gauss linear corrected;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/snGradSchemes/\
"snGradSchemes\n\
{\n\
    default none;               \/\/ unsLinearGeometry\n\
    snGrad(D) corrected;        \/\/ unsLinearGeometry\n\
    snGrad(DD) corrected;       \/\/ unsLinearGeometry\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/interpolationSchemes/\
"interpolationSchemes\n\
{\n\
    default none;\n\
    interpolate(impK) linear;\n\
    interpolate(grad(D)) linear;\n\
    interpolate(sigma0) linear;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/RELAX/\
"relaxationFactors\n\
{\n\
    equations\n\
    {\n\
        \/\/D      0.999;\n\
    }\n\
    fields\n\
    {\n\
        D       0.7;\n\
    }\n\
}"/g $caseDir/system/fvSolution
                if [ "$mesh" = "hex"  ] 
               then
                   cartesianMesh -case $caseDir \
                       > $caseDir/log.cartesianMesh
               elif [ "$mesh" = "tet" ]
               then
                   tetMesh -case $caseDir > $caseDir/log.tetMesh
               fi
            elif [ "$model" = linearGeometryTotalDisplacement ]
    	    then
                echo "Changing 0/D"
                sed -i s/blockS/s/g $caseDir/0/D
                sed -i s/blockF/f/g $caseDir/0/D
                echo "Changing system/fvSolution"
                sed -i s/RELAX/\
"relaxationFactors\n\
{\n\
   \/\/ equations\n\
   \/\/ {\n\
   \/\/     \/\/D      0.999;\n\
   \/\/ }\n\
   \/\/ fields\n\
   \/\/ {\n\
   \/\/     D       0.7;\n\
   \/\/ }\n\
}"/g $caseDir/system/fvSolution
                echo "Changing system/fvSchemes"
                sed -i s/gradSchemes/\
"gradSchemes\n\
{\n\
    \/\/default none;\n\
    \/\/default leastSquares;    \/\/ unsLinearGeometry\n\
    default extendedLeastSquares 0;\
    \/\/linearGeometryTotalDisplacement\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/divSchemes/\
"divSchemes\n\
{\n\
    default Gauss linear;    \/\/ unsLinearGeometry\n\
                             \/\/ linearGeometryTotalDisplacement\n\
    \/\/default none;\n\
    \/\/div(sigma) Gauss linear;\n\
    \/\/div((impK*grad(D))) Gauss linear;\n\
}"/g $caseDir/system/fvSchemes
		sed -i s/laplacianSchemes/\
"laplacianSchemes\n\
{\n\
    \/\/ unsLinearGeometry and\n\
    \/\/ linearGeometryTotalDisplacement\n\
    default none;\n\
    laplacian(DD,D) Gauss linear corrected;\n\
    laplacian(DDD,DD) Gauss linear corrected;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/snGradSchemes/\
"snGradSchemes\n\
{\n\
    \/\/ unsLinearGeometry and\n\
    \/\/ linearGeometryTotalDisplacement\n\
    default none;\n\
    snGrad(D) corrected;\n\
    snGrad(DD) corrected;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/interpolationSchemes/\
"interpolationSchemes\n\
{\n\
    \/\/ unsLinearGeometry and\n\
    \/\/ linearGeometryTotalDisplacement\n\
    default none;\n\
    interpolate(impK) linear;\n\
    interpolate(grad(D)) linear;\n\
    \/\/ only unsLinearGeometry\n\
    \/\/interpolate(sigma0) linear;\n\
    \/\/ only linearGeometryTotalDisplacement\n\
    interpolate(grad(DD)) linear;\n\
    interpolate(grad(sigmaHyd)) linear;\n\
}"/g $caseDir/system/fvSchemes
                if [ "$mesh" = "hex"  ] 
                then
                    cartesianMesh -case $caseDir \
                        > $caseDir/log.cartesianMesh
                elif [ "$mesh" = "tet" ]
                then
                    tetMesh -case $caseDir > $caseDir/log.tetMesh
                fi
            elif [ "$model" = "linearGeometry" ]
            then
                echo "Changing 0/D"
                sed -i s/blockS/s/g $caseDir/0/D
                sed -i s/blockF/f/g $caseDir/0/D
                echo "Changing system/fvSolution"
                sed -i s/RELAX/\
"relaxationFactors\n\
{\n\
   \/\/ equations\n\
   \/\/ {\n\
   \/\/     \/\/D      0.999;\n\
   \/\/ }\n\
   \/\/ fields\n\
   \/\/ {\n\
   \/\/     D       0.7;\n\
   \/\/ }\n\
}"/g $caseDir/system/fvSolution
                echo "Changing system/fvSchemes"
                sed -i s/gradSchemes/\
"gradSchemes\n\
{\n\
    \/\/default none;\n\
    \/\/default leastSquares;    \/\/ unsLinearGeometry\n\
    \/\/linearGeometryTotalDisplacement and\n\
    \/\/linearGeometry\n\
    default extendedLeastSquares 0;\n\   
}"/g $caseDir/system/fvSchemes
                sed -i s/divSchemes/\
"divSchemes\n\
{\n\
    default Gauss linear;    \/\/ unsLinearGeometry\n\
                             \/\/ linearGeometryTotalDisplacement\n\
                             \/\/ linearGeometry\n\
    \/\/default none;\n\
    \/\/div(sigma) Gauss linear;\n\
    \/\/div((impK*grad(D))) Gauss linear;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/laplacianSchemes/\
"laplacianSchemes\n\
{\n\
    \/\/ unsLinearGeometry and\n\
    \/\/ linearGeometryTotalDisplacement and\n\
    \/\/ linearGeometry\n\
    default none;\n\
    laplacian(DD,D) Gauss linear corrected;\n\
    laplacian(DDD,DD) Gauss linear corrected;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/snGradSchemes/\
"snGradSchemes\n\
{\n\
    \/\/ unsLinearGeometry and\n\
    \/\/ linearGeometryTotalDisplacement and\n\
    \/\/ linearGeometry\n\
    default none;\n\
    snGrad(D) corrected;\n\
    snGrad(DD) corrected;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/interpolationSchemes/\
"interpolationSchemes\n\
{\n\
    \/\/ unsLinearGeometry and\n\
    \/\/ linearGeometryTotalDisplacement and\n\
    \/\/ linearGeometry\n\
    default none;\n\
    interpolate(impK) linear;\n\
    interpolate(grad(D)) linear;\n\
    \/\/ only unsLinearGeometry\n\
    \/\/interpolate(sigma0) linear;\n\
    \/\/ linearGeometryTotalDisplacement and\n\
    \/\/ linearGeometry\n\
    interpolate(grad(DD)) linear;\n\
    \/\/ only linearGeometryTotalDisplacement\n\
    \/\/interpolate(grad(sigmaHyd)) linear;\n\
}"/g $caseDir/system/fvSchemes
                if [ "$mesh" = "hex"  ] 
                then
                    cartesianMesh -case $caseDir \
                        > $caseDir/log.cartesianMesh
                elif [ "$mesh" = "tet" ]
                then
                    tetMesh -case $caseDir > $caseDir/log.tetMesh
                fi
            elif [ "$model" = "coupledUnsLinearGeometryLinearElastic" ]
            then
                echo "Changing system/fvSolution"
                sed -i s/RELAX/\
"relaxationFactors\n\
{\n\
   \/\/ equations\n\
   \/\/ {\n\
   \/\/     \/\/D      0.999;\n\
   \/\/ }\n\
   \/\/ fields\n\
   \/\/ {\n\
   \/\/     D       0.7;\n\
   \/\/ }\n\
}"/g $caseDir/system/fvSolution
                echo "Changing system/fvSchemes"
                sed -i s/gradSchemes/\
"gradSchemes\n\
{\n\
    default none;\n\
    \/\/default extendedLeastSquares 0;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/divSchemes/\
"divSchemes\n\
{\n\
    default none;\n\
    fvmDiv(sigma) pointGaussLeastSquares;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/laplacianSchemes/\
"laplacianSchemes\n\
{\n\
    default none;\n\
    fvmBlockLaplacian(D)    pointGaussLeastSquaresLaplacian;\n\
    fvmBlockLaplacianTranspose(D) pointGaussLeastSquaresLaplacianTranspose;\n\
    fvmBlockLaplacianTrace(D) pointGaussLeastSquaresLaplacianTrace;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/snGradSchemes/\
"snGradSchemes\n\
{\n\
    default none;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/interpolationSchemes/\
"interpolationSchemes\n\
{\n\
    default                 none;\n\
    mu                      linear;\n\
    lambda                  linear;\n\
}"/g $caseDir/system/fvSchemes
                if [ "$mesh" = "hex" ]
                then
                    cartesianMesh -case $caseDir \
                        > $caseDir/log.cartesianMesh
                elif [ "$mesh" = "tet" ]
                then
                    tetMesh -case $caseDir > $caseDir/log.tetMesh
                fi
            elif [ "$model" = "coupledStabilised" ]
            then
                #echo "Changing constant/solidProperties"
                echo "Changing system/fvSolution"
                sed -i s/RELAX/\
"relaxationFactors\n\
{\n\
   \/\/ equations\n\
   \/\/ {\n\
   \/\/     \/\/D      0.999;\n\
   \/\/ }\n\
   \/\/ fields\n\
   \/\/ {\n\
   \/\/     D       0.7;\n\
   \/\/ }\n\
}"/g $caseDir/system/fvSolution
                echo "Changing system/fvSchemes"
                sed -i s/gradSchemes/\
"gradSchemes\n\
{\n\
    default none;\n\
    grad(D) leastSquares;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/divSchemes/\
"divSchemes\n\
{\n\
    default none;\n\
    fvmDiv(sigma) pointGaussLeastSquares;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/laplacianSchemes/\
"laplacianSchemes\n\
{\n\
    default none;\n\
    fvmBlockLaplacian(D)    pointGaussLeastSquaresLaplacian;\n\
    fvmBlockLaplacianTranspose(D) pointGaussLeastSquaresLaplacianTranspose;\n\
    fvmBlockLaplacianTrace(D) pointGaussLeastSquaresLaplacianTrace;\n\
    laplacian(DDD,DD)       Gauss linear corrected;\n\
    laplacian(DD,D)       Gauss linear corrected;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/snGradSchemes/\
"snGradSchemes\n\
{\n\
    default none;\n\
}"/g $caseDir/system/fvSchemes
                sed -i s/interpolationSchemes/\
"interpolationSchemes\n\
{\n\
    default                 none;\n\
    mu                      linear;\n\
    lambda                  linear;\n\
    interpolate(impK)       linear;\n\
    interpolate(grad(DD))   linear;\n\
    interpolate(grad(D))    linear;\n\
}"/g $caseDir/system/fvSchemes
                if [ "$mesh" = "hex" ]
                then
                    cartesianMesh -case $caseDir \
                       > $caseDir/log.cartesianMesh
                elif [ "$mesh" = "tet" ]
	        then
                    tetMesh -case $caseDir > $caseDir/log.tetMesh
                fi
            else
                echo "The model is not implemented."
            fi

	    # Processing
	    echo "solving for $caseDir..."
	    solids4Foam -case $caseDir &> $caseDir/log.solids4Foam

	    # Post-processing (sampling)
	    foamCalc components sigma -latestTime -case $caseDir &> \
	    $caseDir/log.foamCalc
	    echo "sampling for $caseDir..."
            source Allsample.sh
        done
    #done
done

#------------------------------------------------------------------------------
