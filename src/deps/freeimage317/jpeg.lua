project "jpeg"
  kind "StaticLib"
  language "C"

  removeplatforms "emscripten"

  files {
    "src/Source/LibJPEG/jaricom.c", "src/Source/LibJPEG/jcapimin.c", "src/Source/LibJPEG/jcapistd.c", "src/Source/LibJPEG/jcarith.c", "src/Source/LibJPEG/jccoefct.c", "src/Source/LibJPEG/jccolor.c", "src/Source/LibJPEG/jcdctmgr.c", "src/Source/LibJPEG/jchuff.c", "src/Source/LibJPEG/jcinit.c", "src/Source/LibJPEG/jcmainct.c", "src/Source/LibJPEG/jcmarker.c", "src/Source/LibJPEG/jcmaster.c", "src/Source/LibJPEG/jcomapi.c", "src/Source/LibJPEG/jcparam.c", "src/Source/LibJPEG/jcprepct.c", "src/Source/LibJPEG/jcsample.c", "src/Source/LibJPEG/jctrans.c", "src/Source/LibJPEG/jdapimin.c", "src/Source/LibJPEG/jdapistd.c", "src/Source/LibJPEG/jdarith.c", "src/Source/LibJPEG/jdatadst.c", "src/Source/LibJPEG/jdatasrc.c", "src/Source/LibJPEG/jdcoefct.c", "src/Source/LibJPEG/jdcolor.c", "src/Source/LibJPEG/jddctmgr.c", "src/Source/LibJPEG/jdhuff.c", "src/Source/LibJPEG/jdinput.c", "src/Source/LibJPEG/jdmainct.c", "src/Source/LibJPEG/jdmarker.c", "src/Source/LibJPEG/jdmaster.c", "src/Source/LibJPEG/jdmerge.c", "src/Source/LibJPEG/jdpostct.c", "src/Source/LibJPEG/jdsample.c", "src/Source/LibJPEG/jdtrans.c", "src/Source/LibJPEG/jerror.c", "src/Source/LibJPEG/jfdctflt.c", "src/Source/LibJPEG/jfdctfst.c", "src/Source/LibJPEG/jfdctint.c", "src/Source/LibJPEG/jidctflt.c", "src/Source/LibJPEG/jidctfst.c", "src/Source/LibJPEG/jidctint.c", "src/Source/LibJPEG/jmemmgr.c", "src/Source/LibJPEG/jmemnobs.c", "src/Source/LibJPEG/jquant1.c", "src/Source/LibJPEG/jquant2.c", "src/Source/LibJPEG/jutils.c", "src/Source/LibJPEG/transupp.c"
  }
