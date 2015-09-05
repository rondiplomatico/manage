# ==============================
# Build configuration
# ==============================

# Precision to build (if applicable)
# Valid choices are s,d,c,z and any combinations.
# s: Single / float precision
# d: Double precision
# c: Complex / float precision
# z: Complex / double precision
set(BUILD_PRECISION sd CACHE STRING "Build precisions for OpenCMISS components. Choose any of [sdcz]")

# The integer types that can be used (if applicable)
# Used only by PASTIX yet
set(INT_TYPE int32 CACHE STRING "OpenCMISS integer type (only used by PASTIX yet)")

# Always build tests.
option(BUILD_TESTS "Build OpenCMISS(-components) tests" ON)

option(PARALLEL_BUILDS "Use multithreading (-jN etc) for builds" ON)

# Type of libraries to build
# The default is static for all dependencies and shared for main components (iron and zinc)
# If set to yes, every component will 
option(BUILD_SHARED_LIBS "Build shared libraries within/for every component" NO)

# Have the build system wrap the builds of component into log files.
# Selecting NO will directly print the build process to the standard output.
set(OCM_CREATE_LOGS YES)

# Debug postfix
set(CMAKE_DEBUG_POSTFIX d CACHE STRING "Debug postfix for library names of DEBUG-builds")

# ==============================
# Compilers
# ==============================
# Flag for DEBUG configuration builds only!
set(OCM_WARN_ALL YES)
set(OCM_CHECK_ALL YES)

# ==============================
# Multithreading
# This controls openmp/OpenAcc
# ==============================
option(OCM_USE_MT "Use multithreading in OpenCMISS (where applicable)" NO)

# ==============================
# Defaults for all dependencies
# ==============================
# This is changeable in the OpenCMISSLocalConfig file
set(OCM_COMPONENTS_SYSTEM DEFAULT)

foreach(OCM_DEP ${OPENCMISS_COMPONENTS})
    set(_VALUE YES)
    if (${OCM_DEP} IN_LIST OPENCMISS_COMPONENTS_DISABLED_BY_DEFAULT)
        set(_VALUE NO)
    endif()
    # Use everything but the components in OPENCMISS_COMPONENTS_DISABLED_BY_DEFAULT
    set(OCM_USE_${OCM_DEP} ${_VALUE})
    
    # Look for some components on the system first before building
    set(_VALUE NO)
    if (${OCM_DEP} IN_LIST OPENCMISS_COMPONENTS_SYSTEM_BY_DEFAULT)
        set(_VALUE YES)
    endif()
    set(OCM_SYSTEM_${OCM_DEP} ${_VALUE})
    # Initialize the default: static build for all components
    set(${OCM_DEP}_SHARED NO)
endforeach()

# Main version
set(OPENCMISS_VERSION 1.0)

# Component versions
set(BLAS_VERSION 3.5.0)
set(HYPRE_VERSION 2.10.0) # Alternatives: 2.9.0
set(LAPACK_VERSION 3.5.0)
set(LIBCELLML_VERSION 1.0)
set(METIS_VERSION 5.1)
set(MUMPS_VERSION 5.0.0) # Alternatives: 4.10.0
set(PASTIX_VERSION 5.2.2.16)
set(PARMETIS_VERSION 4.0.3)
set(PETSC_VERSION 3.5)
set(PLAPACK_VERSION 3.0)
set(PTSCOTCH_VERSION 6.0.3)
set(SCALAPACK_VERSION 2.8)
set(SCOTCH_VERSION 6.0.3)
set(SLEPC_VERSION 3.5)
set(SOWING_VERSION 1.1.16)
set(SUITESPARSE_VERSION 4.4.0)
set(SUNDIALS_VERSION 2.5)
set(SUPERLU_VERSION 4.3)
set(SUPERLU_DIST_VERSION 3.3)
set(ZLIB_VERSION 1.2.3)
set(BZIP2_VERSION 1.0.6) # Alternatives: 1.0.5
set(FIELDML-API_VERSION 0.5.0)
set(LIBXML2_VERSION 2.7.6)
set(LLVM_VERSION 3.4)
set(GTEST_VERSION 1.7.0)
set(SZIP_VERSION 2.1)
set(HDF5_VERSION 1.8.14)
set(JPEG_VERSION 6.0.0)
set(NETGEN_VERSION 4.9.11)
set(FREETYPE_VERSION 2.4.10)
set(FTGL_VERSION 2.1.3)
set(GLEW_VERSION 1.5.5)
set(OPTPP_VERSION 681)
set(PNG_VERSION 1.5.2)
set(TIFF_VERSION 4.0.5)# Alternatives: 3.8.2
set(GDCM_VERSION 2.0.12)
set(IMAGEMAGICK_VERSION 6.7.0.8)
set(ITK_VERSION 3.20.0)

# MPI
set(OPENMPI_VERSION 1.8.4)
set(MPICH_VERSION 3.1.3)
set(MVAPICH2_VERSION 2.1)
# Cellml
set(CELLML_VERSION 1.0) # any will do, not used
set(CSIM_VERSION 1.0)

# will be "master" finally
set(IRON_BRANCH iron)
# Needs to be here until the repo's name is "iron", then it's compiled automatically (see Iron.cmake/BuildMacros)
set(IRON_REPO https://github.com/rondiplomatico/iron)
set(IRON_SHARED YES)
set(ZINC_SHARED YES)

set(EXAMPLES_REPO https://github.com/rondiplomatico/examples)
set(EXAMPLES_BRANCH cmake)

set(ZINC_BRANCH master)
set(ZINC_REPO https://github.com/hsorby/zinc)

# ==========================================================================================
# Single module configuration
#
# These flags only apply if the corresponding package is build
# by the OpenCMISS Dependencies system. The packages themselves will then search for the
# appropriate consumed packages. No checks are performed on whether the consumed packages
# will also be build by us or not, as they might be provided externally.
#
# To be safe: E.g. if you wanted to use MUMPS with SCOTCH, also set OCM_USE_SCOTCH=YES so that
# the build system ensures that SCOTCH will be available.
# ==========================================================================================
set(MUMPS_WITH_SCOTCH NO)
set(MUMPS_WITH_PTSCOTCH YES)
set(MUMPS_WITH_METIS NO)
set(MUMPS_WITH_PARMETIS YES)

set(SUNDIALS_WITH_LAPACK YES)

set(SCOTCH_USE_THREADS YES)
set(SCOTCH_WITH_ZLIB YES)
set(SCOTCH_WITH_BZIP2 YES)

set(SUPERLU_DIST_WITH_PARMETIS YES)

set(PASTIX_USE_THREADS YES)
set(PASTIX_USE_METIS YES)
set(PASTIX_USE_PTSCOTCH YES)

set(HDF5_WITH_MPI NO)
set(HDF5_WITH_SZIP YES)
set(HDF5_WITH_ZLIB YES)

set(FIELDML-API_WITH_HDF5 NO)
set(FIELDML-API_WITH_JAVA_BINDINGS NO)
set(FIELDML-API_WITH_FORTRAN_BINDINGS YES)

set(IRON_WITH_CELLML YES)
set(IRON_WITH_FIELDML NO)
set(IRON_WITH_HYPRE YES)
set(IRON_WITH_SUNDIALS YES)
set(IRON_WITH_MUMPS YES)
set(IRON_WITH_SCALAPACK YES)
set(IRON_WITH_PETSC YES)

set(LIBXML2_WITH_ZLIB YES)
