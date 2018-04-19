PROG_NOINST = coregtkgen

SUBDIRS = Output

SRCS = main.m XMLReader/XMLReader.m GIR/GIRApi.m GIR/GIRArray.m GIR/GIRBase.m GIR/GIRClass.m GIR/GIRConstant.m GIR/GIRConstructor.m GIR/GIRDoc.m GIR/GIREnumeration.m GIR/GIRField.m GIR/GIRFunction.m GIR/GIRImplements.m GIR/GIRInterface.m GIR/GIRParameter.m GIR/GIRProperty.m GIR/GIRMember.m GIR/GIRMethod.m GIR/GIRNamespace.m GIR/GIRPrerequisite.m GIR/GIRReturnValue.m GIR/GIRType.m GIR/GIRVarargs.m GIR/GIRVirtualMethod.m Generator/CGTKClassWriter.m Generator/CGTKClass.m Generator/CGTKMethod.m Generator/CGTKParameter.m Generator/CGTKUtil.m Gir2Objc.m

include ../buildsys.mk

CPPFLAGS += -I ./ -I ./GIR -I ./Generator -I ./BaseClasses

LD = ${OBJC}

Output: run

run: ${PROG_NOINST}
	./${PROG_NOINST}
