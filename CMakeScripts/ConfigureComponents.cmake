# Main components config
# This script sets up all the different components by either looking them up on the system or adding an external project
# to build them ourselves.
#
# The main sections are Utils, Dependencies and Iron.
#
# The main macro is ADD_COMPONENT defined in OCMSetupBuildMacros.cmake.
# Its behaviour is controlled (despite the direct argument) by
# SUBGROUP_PATH: Determines a grouping folder to sort components into.
# GITHUB_ORGANIZATION: For the default source locations, we use the OpenCMISS github organizations to group the components sources.
#                      Those are used to both clone the git repo in development mode or generate the path to the zipped source file on github. 

# ================================================================
# Utils 
#  -as long as we dont have more utilities i wont change everything to have that in the "Utilities.cmake" script
#   we probably also dont need the release/debug versions here. we'll see what logic we need to extract from the build macros script
# ================================================================ 

# gTest
if (OCM_USE_GTEST AND BUILD_TESTS)
    SET(GTEST_FWD_DEPS LLVM CSIM)
    set(SUBGROUP_PATH utilities)
    set(GITHUB_ORGANIZATION OpenCMISS-Utilities)
    ADD_COMPONENT(GTEST)
endif()

# ================================================================
# Dependencies
# ================================================================
# Forward/downstream dependencies (for cmake build ordering and dependency checking)
# Its organized this way as not all backward dependencies might be built by the cmake
# system. here, the actual dependency list is filled "as we go" and actually build
# packages locally, see ADD_DOWNSTREAM_DEPS in BuildMacros.cmake

# Affects the ADD_COMPONENT macro
set(SUBGROUP_PATH dependencies)
set(GITHUB_ORGANIZATION OpenCMISS-Dependencies)

# Note: The following order for all packages has to be in their interdependency order,
# i.e. mumps may need scotch so scotch has to be processed first on order to be added to the
# external project dependencies list of any following package

# LAPACK (includes BLAS)
if (OCM_USE_BLAS OR OCM_USE_LAPACK)
    if(OCM_SYSTEM_BLAS)
        find_package(BLAS ${BLAS_VERSION} QUIET)
    endif()
    if(OCM_SYSTEM_LAPACK)
        find_package(LAPACK ${LAPACK_VERSION} QUIET)
    endif()
    if(NOT (LAPACK_FOUND AND BLAS_FOUND))
        SET(LAPACK_FWD_DEPS SCALAPACK SUITESPARSE MUMPS
            SUPERLU SUPERLU_DIST PARMETIS HYPRE SUNDIALS PASTIX PLAPACK PETSC IRON)
        ADD_COMPONENT(LAPACK)
    endif()
endif()

# zLIB
if(OCM_USE_ZLIB)
    if(OCM_SYSTEM_ZLIB)
        FIND_PACKAGE(ZLIB QUIET)
    endif()
    if(NOT ZLIB_FOUND)
        SET(ZLIB_FWD_DEPS SCOTCH PTSCOTCH MUMPS LIBXML2 FIELDML-API IRON CSIM LLVM)
        ADD_COMPONENT(ZLIB)
    endif()
endif()

# bzip2
if(OCM_USE_BZIP2)
    if(OCM_SYSTEM_BZIP2)
        FIND_PACKAGE(BZIP2 QUIET)
    endif()
    if(NOT BZIP2_FOUND)
        SET(BZIP2_FWD_DEPS SCOTCH PTSCOTCH)
        ADD_COMPONENT(BZIP2)
    endif()
endif()

# libxml2
if(OCM_USE_LIBXML2)
    if(OCM_SYSTEM_LIBXML2)
        FIND_PACKAGE(LibXml2 QUIET)
    endif()
    if(NOT LIBXML2_FOUND)
        SET(LIBXML2_FWD_DEPS CSIM LLVM FIELDML-API)
        ADD_COMPONENT(LIBXML2
            WITH_ZLIB=${LIBXML2_WITH_ZLIB}
            ZLIB_VERSION=${ZLIB_VERSION}
        )
    endif()
endif()

# fieldml
if(OCM_USE_FIELDML-API)
    if(OCM_SYSTEM_FIELDML-API)
        FIND_PACKAGE(FIELDML-API QUIET)
    endif()
    if(NOT FIELDML-API_FOUND)
        SET(FIELDML-API_FWD_DEPS IRON)
        ADD_COMPONENT(FIELDML-API)
    endif()
endif()

# Scotch 6.0
if (OCM_USE_PTSCOTCH)
    if (OCM_SYSTEM_PTSCOTCH)
        FIND_PACKAGE(PTSCOTCH ${PTSCOTCH_VERSION} QUIET)
    endif()
    if(NOT PTSCOTCH_FOUND)
        SET(SCOTCH_FWD_DEPS PASTIX PETSC MUMPS IRON)
        ADD_COMPONENT(SCOTCH
            BUILD_PTSCOTCH=YES
            USE_ZLIB=${SCOTCH_WITH_ZLIB}
            ZLIB_VERSION=${ZLIB_VERSION}
            USE_BZ2=${SCOTCH_WITH_BZIP2}
            BZIP2_VERSION=${BZIP2_VERSION}
            USE_THREADS=${SCOTCH_USE_THREADS})
    endif()
elseif(OCM_USE_SCOTCH)
    if(OCM_SYSTEM_SCOTCH)
        FIND_PACKAGE(SCOTCH ${SCOTCH_VERSION} QUIET)
    endif()
    if(NOT SCOTCH_FOUND)
        SET(PTSCOTCH_FWD_DEPS PASTIX PETSC MUMPS IRON)
        ADD_COMPONENT(SCOTCH
            BUILD_PTSCOTCH=NO
            USE_ZLIB=${SCOTCH_WITH_ZLIB}
            ZLIB_VERSION=${ZLIB_VERSION}
            USE_BZ2=${SCOTCH_WITH_BZIP2}
            BZIP2_VERSION=${BZIP2_VERSION}
            USE_THREADS=${SCOTCH_USE_THREADS})
    endif()
endif()

# PLAPACK
if(OCM_USE_PLAPACK)
    if(OCM_SYSTEM_PLAPACK)
        FIND_PACKAGE(PLAPACK QUIET)
    endif()
    if(NOT PLAPACK_FOUND)
        SET(PLAPACK_FWD_DEPS IRON)
        ADD_COMPONENT(PLAPACK
            BLAS_VERSION=${BLAS_VERSION}
            LAPACK_VERSION=${LAPACK_VERSION})
    endif()
endif()

# ScaLAPACK
if(OCM_USE_SCALAPACK)
    if(OCM_SYSTEM_SCALAPACK)
        FIND_PACKAGE(SCALAPACK ${SCALAPACK_VERSION} QUIET)
    endif()
    if(NOT SCALAPACK_FOUND)
        SET(SCALAPACK_FWD_DEPS MUMPS PETSC IRON)
        ADD_COMPONENT(SCALAPACK
            BLAS_VERSION=${BLAS_VERSION}
            LAPACK_VERSION=${LAPACK_VERSION})
    endif()
endif()

# parMETIS 4 (+METIS 5)
if(OCM_USE_PARMETIS)
    if(OCM_SYSTEM_PARMETIS)
        FIND_PACKAGE(PARMETIS ${PARMETIS_VERSION} QUIET)
    endif()
    if(NOT PARMETIS_FOUND)
        SET(PARMETIS_FWD_DEPS MUMPS SUITESPARSE SUPERLU_DIST PASTIX IRON)
        ADD_COMPONENT(PARMETIS)
    endif()
endif()

# MUMPS
if (OCM_USE_MUMPS)
    if(OCM_SYSTEM_MUMPS)
        FIND_PACKAGE(MUMPS ${MUMPS_VERSION} QUIET)
    endif()
    if(NOT MUMPS_FOUND)
        SET(MUMPS_FWD_DEPS PETSC IRON)
        ADD_COMPONENT(MUMPS
            USE_SCOTCH=${MUMPS_WITH_SCOTCH}
            USE_PTSCOTCH=${MUMPS_WITH_PTSCOTCH}
            PTSCOTCH_VERSION=${PTSCOTCH_VERSION}
            SCOTCH_VERSION=${SCOTCH_VERSION}
            SCOTCH_WITH_ZLIB=${SCOTCH_WITH_ZLIB} #Dirty hack, see mumps dependency main CMakeLists.txt
            ZLIB_VERSION=${ZLIB_VERSION} # Belongs to dirty hack
            USE_PARMETIS=${MUMPS_WITH_PARMETIS}
            PARMETIS_VERSION=${PARMETIS_VERSION}
        )
    endif()
endif()

# SUITESPARSE [CHOLMOD / UMFPACK]
if (OCM_USE_SUITESPARSE)
    if(OCM_SYSTEM_SUITESPARSE)
        FIND_PACKAGE(SUITESPARSE ${SUITESPARSE_VERSION} QUIET)
    endif()
    if(NOT SUITESPARSE_FOUND)
        SET(SUITESPARSE_FWD_DEPS PETSC IRON)
        ADD_COMPONENT(SUITESPARSE
            BLAS_VERSION=${BLAS_VERSION}
            LAPACK_VERSION=${LAPACK_VERSION}
            METIS_VERSION=${METIS_VERSION})
    endif()
endif()

# Hypre 2.9.0b
if (OCM_USE_HYPRE)
    if(OCM_SYSTEM_HYPRE)
        FIND_PACKAGE(HYPRE ${HYPRE_VERSION} QUIET)
    endif()
    if(NOT HYPRE_FOUND)
        SET(HYPRE_FWD_DEPS PETSC IRON)
        ADD_COMPONENT(HYPRE
            BLAS_VERSION=${BLAS_VERSION}
            LAPACK_VERSION=${LAPACK_VERSION})
    endif()
endif()

# SuperLU 4.3
if (OCM_USE_SUPERLU)
    if(OCM_SYSTEM_SUPERLU)
        FIND_PACKAGE(SUPERLU ${SUPERLU_VERSION} QUIET)
    endif()
    if(NOT SUPERLU_FOUND)
        SET(SUPERLU_FWD_DEPS PETSC IRON)
        ADD_COMPONENT(SUPERLU
            BLAS_VERSION=${BLAS_VERSION}
            LAPACK_VERSION=${LAPACK_VERSION})
    endif()
endif()

# SuperLU-DIST 4.0
if (OCM_USE_SUPERLU_DIST)
    if(OCM_SYSTEM_SUPERLU_DIST)
        FIND_PACKAGE(SUPERLU_DIST ${SUPERLU_DIST_VERSION} QUIET)
    endif()
    if(NOT SUPERLU_DIST_FOUND)
        SET(SUPERLU_DIST_FWD_DEPS PETSC IRON)
        ADD_COMPONENT(SUPERLU_DIST
            BLAS_VERSION=${BLAS_VERSION}
            USE_PARMETIS=${SUPERLU_DIST_WITH_PARMETIS}
            PARMETIS_VERSION=${PARMETIS_VERSION}
            USE_METIS=${SUPERLU_DIST_WITH_METIS}
            METIS_VERSION=${METIS_VERSION}
        )
    endif()
endif()

# Sundials 2.5
if (OCM_USE_SUNDIALS)
    if(OCM_SYSTEM_SUNDIALS)
        FIND_PACKAGE(SUNDIALS ${SUNDIALS_VERSION} QUIET)
    endif()
    if(NOT SUNDIALS_FOUND)
        SET(SUNDIALS_FWD_DEPS CSIM PETSC IRON)
        ADD_COMPONENT(SUNDIALS
            USE_LAPACK=${SUNDIALS_WITH_LAPACK}
            BLAS_VERSION=${BLAS_VERSION}
            LAPACK_VERSION=${LAPACK_VERSION})
    endif()
endif()

# Pastix 5.2.2.16
if (OCM_USE_PASTIX)
    if(OCM_SYSTEM_PASTIX)
        FIND_PACKAGE(PASTIX ${PASTIX_VERSION} QUIET)
    endif()
    if(NOT PASTIX_FOUND)
        SET(PASTIX_FWD_DEPS PETSC IRON)
        ADD_COMPONENT(PASTIX
            USE_THREADS=${PASTIX_USE_THREADS}
            USE_METIS=${PASTIX_USE_METIS}
            USE_PTSCOTCH=${PASTIX_USE_PTSCOTCH}
            SCOTCH_WITH_ZLIB=${SCOTCH_WITH_ZLIB} #Dirty hack, see mumps dependency main CMakeLists.txt
            ZLIB_VERSION=${ZLIB_VERSION} # Belongs to dirty hack
        )
    endif()
endif()

# Sowing (only for PETSC ftn-auto generation)
if (OCM_USE_SOWING)
    if(OCM_SYSTEM_SOWING)
        FIND_PACKAGE(SOWING ${SOWING_VERSION} QUIET)
    endif()
    if(NOT SOWING_FOUND)
        SET(SOWING_FWD_DEPS PETSC)
        ADD_COMPONENT(SOWING)
    endif()
endif()

# PETSc 3.5
if (OCM_USE_PETSC)
    if(OCM_SYSTEM_PETSC)
        FIND_PACKAGE(PETSC ${PETSC_VERSION} QUIET)
    endif()
    if(NOT PETSC_FOUND)
        SET(PETSC_FWD_DEPS SLEPC IRON)
        ADD_COMPONENT(PETSC
            HYPRE_VERSION=${HYPRE_VERSION}
            MUMPS_VERSION=${MUMPS_VERSION}
            PARMETIS_VERSION=${PARMETIS_VERSION}
            PASTIX_VERSION=${PASTIX_VERSION}
            PTSCOTCH_VERSION=${PTSCOTCH_VERSION}
            SCALAPACK_VERSION=${SCALAPACK_VERSION}
            SUITESPARSE_VERSION=${SUITESPARSE_VERSION}
            SUNDIALS_VERSION=${SUNDIALS_VERSION}
            SUPERLU_VERSION=${SUPERLU_VERSION}
            SUPERLU_DIST_VERSION=${SUPERLU_DIST_VERSION}
            SCOTCH_WITH_ZLIB=${SCOTCH_WITH_ZLIB} #Dirty hack, see petsc dependency main CMakeLists.txt
            ZLIB_VERSION=${ZLIB_VERSION} # Belongs to dirty hack
        )
    endif()
endif()

# SLEPc 3.5
if (OCM_USE_SLEPC)
    if(OCM_SYSTEM_SLEPC)
        FIND_PACKAGE(SLEPC ${SLEPC_VERSION} QUIET)
    endif()
    if(NOT SLEPC_FOUND)
        SET(SLEPC_FWD_DEPS IRON)
        ADD_COMPONENT(SLEPC
            HYPRE_VERSION=${HYPRE_VERSION}
            MUMPS_VERSION=${MUMPS_VERSION}
            PARMETIS_VERSION=${PARMETIS_VERSION}
            PASTIX_VERSION=${PASTIX_VERSION}
            PETSC_VERSION=${PETSC_VERSION}
            PTSCOTCH_VERSION=${PTSCOTCH_VERSION}
            SCALAPACK_VERSION=${SCALAPACK_VERSION}
            SUITESPARSE_VERSION=${SUITESPARSE_VERSION}
            SUNDIALS_VERSION=${SUNDIALS_VERSION}
            SUPERLU_VERSION=${SUPERLU_VERSION}
            SUPERLU_DIST_VERSION=${SUPERLU_DIST_VERSION})
    endif()
endif()

# CellML
if (OCM_USE_LIBCELLML)
    SET(LIBCELLML_FWD_DEPS CSIM CELLML IRON)
    ADD_COMPONENT(LIBCELLML)
endif()

if (OCM_USE_CELLML)
    # For now cellml is in OpenCMISS organization on GitHub
    set(GITHUB_ORGANIZATION OpenCMISS)
    SET(CELLML_FWD_DEPS IRON)
    ADD_COMPONENT(CELLML)
    # Set back
    set(GITHUB_ORGANIZATION OpenCMISS-Dependencies)
endif()

if (OCM_USE_LLVM)
    SET(LLVM_FWD_DEPS CSIM)
    ADD_COMPONENT(LLVM)
endif()
if (OCM_USE_CSIM)
    SET(CSIM_FWD_DEPS IRON)
    ADD_COMPONENT(CSIM)
endif()

# ================================================================
# Iron
# ================================================================
if (OCM_USE_IRON)
    set(SUBGROUP_PATH .)
    set(GITHUB_ORGANIZATION OpenCMISS)
    
    ADD_COMPONENT(IRON
        WITH_CELLML=${IRON_WITH_CELLML}
        WITH_FIELDML=${IRON_WITH_FIELDML} 
        WITH_HYPRE=${IRON_WITH_HYPRE}
        WITH_SUNDIALS=${IRON_WITH_SUNDIALS}
        WITH_MUMPS=${IRON_WITH_MUMPS}
        WITH_SCALAPACK=${IRON_WITH_SCALAPACK}
        WITH_PETSC=${IRON_WITH_PETSC}
    )
endif()

# Notes:
# lapack: not sure if LAPACKE is build/required
# plapack: have only MACHINE_TYPE=500 and MANUFACTURE=50 (linux)
# plapack: some tests are not compiling
# parmetis/metis: test programs not available (but for gklib, and they are also rudimental), linking executables instead to have a 50% "its working" test
# mumps - not setup for libseq / sequential version
# mumps - only have double precision arithmetics
# mumps - no PORD is compiled (will have parmetis/scotch available)
# mumps - hardcoded Add_ compiler flag for c/fortran interfacing.. dunno if that is the best idea
# metis: have fixed IDXTYPEWIDTH 32
# cholmod: could go with CUDA BLAS version (indicated by makefile)
# umfpack: building only "int" version right now (Suitesparse_long impl for AMD,CAMD etc but not umfpack)


# TODO
# cholmod - use CUDA stuff
