/*---------------------------------------------------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
   \\    /   O peration     |
    \\  /    A nd           | Copyright held by original author
     \\/     M anipulation  |
-------------------------------------------------------------------------------
License
    This file is part of OpenFOAM.

Description
    Mathematical model where linear geometry is assumed i.e. small strains and
    small rotations are assumed.

    A block-coupled solution methodology is employed, in contrast to the
    segregated solution methodology employed in linGeomSolid.

SourceFiles
    coupledStabilised.C

\*---------------------------------------------------------------------------*/

#ifndef coupledStabilised_H
#define coupledStabilised_H

#include "solidModel.H"
#ifdef FOAMEXTEND
    #include "solidPolyMesh.H"
    #include "BlockSolverPerformance.H"
#endif

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

namespace Foam
{

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

namespace solidModels
{

/*---------------------------------------------------------------------------*\
               Class coupledStabilised Declaration
\*---------------------------------------------------------------------------*/

class coupledStabilised
:
    public solidModel
{
    // Private data

#ifdef FOAMEXTEND
        //- The solidPolyMesh stores the additional addressing required for the
        //  extended implicit stencil
        solidPolyMesh extendedMesh_;

        //- Solution vector
        //  This is a field containing the cell displacements followed by the
        //  boundary face displacements
        vectorIOField solutionVec_;
#endif

        //- Hooke's law second Lame parameter, aka shear modulus
        surfaceScalarField muf_;

        //- Hooke's law first Lame parameter
        surfaceScalarField lambdaf_;

    // Private Member Functions

        //- Write banner
        void writeBanner(messageStream& os) const;

        //- Disallow default bitwise copy construct
        coupledStabilised
        (
            const coupledStabilised&
        );

        //- Disallow default bitwise assignment
        void operator=(const coupledStabilised&);


protected:

    // Protected member functions

        //- Return nonlinear geometry enumerator
        virtual nonLinearGeometry::nonLinearType nonLinGeom() const
        {
            return nonLinearGeometry::LINEAR_GEOMETRY;
        }


public:

    //- Runtime type information
    TypeName("coupledStabilised");

    // Constructors

        //- Construct from components
        coupledStabilised
        (
            Time& runTime,
            const word& region = dynamicFvMesh::defaultRegion
        );



    // Destructor

        virtual ~coupledStabilised()
        {}


    // Member Functions

        // Access

            //- Each solidModel must indicate whether D or DD is the primary
            //  solution variable
            virtual volVectorField& solutionD()
            {
                // This model solves for D
                return D();
            }

        // Edit

            //- Evolve the solid solver and solve the mathematical model
            virtual bool evolve();

            //- Traction boundary surface normal gradient
            virtual tmp<vectorField> tractionBoundarySnGrad
            (
                const vectorField& traction,
                const scalarField& pressure,
                const fvPatch& patch
            ) const;
};


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

} // End namespace solidModel

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

} // End namespace Foam

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

#endif

// ************************************************************************* //
