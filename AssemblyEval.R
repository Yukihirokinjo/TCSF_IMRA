#
# AssemblyEval.R
# ver. 2.7.3
#

args      <- commandArgs(trailingOnly=T)
OutDir    <- args[1]
Ite       <- args[2]
InContigs <- args[3]
LibDir    <- args[4]

#chooseCRANmirror(graphics=FALSE, ind=49)

#if(!require(seqinr)){.libPaths(LibDir)} 
#install.packages("seqinr", lib=LibDir)
library(seqinr, lib.loc = LibDir)

# Function definition: assembly statistics calculations
NxCal <- function(Val,Seq){

  Lengths <- rep(0, length(Seq))
  for(i in 1:length(Seq)){ Lengths[i] <- length(Seq[[i]]) }
  numC <- length(Seq)
  sumL <- sum(Lengths)
  maxL <- max(Lengths)

  LengthsS <- sort(Lengths, decreasing = T)
  Xval=( sumL * Val / 100 )
  SumLen   <- 0
  for(n in 1:length(LengthsS)){
    SumLen <- SumLen + LengthsS[n]
    if( SumLen >= Xval){ Nx <- LengthsS[n] ; Lx <- n ; break }
  }

  return(c(numC, sumL, maxL, Nx, Lx))
}
# Function definition: end


Outlog <- paste(OutDir, "tmp_Result.log", sep="/")
Label <- paste("#", "Num.Con", "Num.Sca", "SumLen.C", "SumLen.S", "Max", "N50", "L50", sep="\t")

# Initial status
if(Ite == "Initial"){

  write(Label, file = Outlog,  append = F)

  ContI   <- read.fasta(InContigs, forceDNAtolower = F)
  StatI   <- NxCal(50,ContI)
  numI    <- StatI[[1]]
  SumLenI <- StatI[[2]]
  maxI    <- StatI[[3]]
  N50I    <- StatI[[4]]
  L50I    <- StatI[[5]]

  Init <- paste("0", "-", numI, SumLenI, "-", "-", maxI, N50I, L50I, sep="\t")
  write(Init, file = Outlog, append = T)

  # Write out to std out put
  system(paste("printf", '"', " NumScaffolds = ", numI, "\n", '"', sep=" "))
  system(paste("printf", '"', "SumScaffoldsLength = ", SumLenI, "\n", '"', sep=" "))
  system(paste("printf", '"', "MaxScaffoldLength = ", maxI, "\n", '"', sep=" "))
  system(paste("printf", '"', "Input N50 = ", N50I, "\n", '"', sep=" "))
  system(paste("printf", '"', "Input L50 = ", L50I, "\n\n", '"', sep=" "))

}else{

  # Contigs
  ContigsL <-paste(OutDir, "Assembly", Ite, "IMRA-Contigs.fasta", sep="/")
  ContL   <- read.fasta(ContigsL, forceDNAtolower = F)
  StatL   <- NxCal(50,ContL)
  numL    <- StatL[[1]]
  SumLenL <- StatL[[2]]
  maxL    <- StatL[[3]]
  N50L    <- StatL[[4]]
  L50L    <- StatL[[5]]

  # Scaffolds
  ContigsS <- paste(OutDir, "Assembly", Ite, "IMRA-Scaffolds.fasta", sep="/")
  ContS   <- read.fasta(ContigsS, forceDNAtolower = F)
  StatS   <- NxCal(50,ContS)
  numS    <- StatS[[1]]
  SumLenS <- StatS[[2]]
  maxS    <- StatS[[3]]
  N50S    <- StatS[[4]]
  L50S    <- StatS[[5]]

  # Write result.log file
  IteResult <- paste(Ite, numL, numS, SumLenL, SumLenS, maxS, N50S, L50S, sep="\t")
  write(IteResult, file = Outlog,  append = F)

  # Write fasta files
  FnameL     <- paste("Contigs_", Ite, ".fasta", sep="")
  Dir_FnameL <- paste(OutDir, "Contigs", FnameL, sep="/")
  write.fasta(ContL, names(ContL), file.out = Dir_FnameL )

  FnameS     <- paste("Scaffolds_", Ite, ".fasta", sep="")
  Dir_FnameS <- paste(OutDir, "Contigs", FnameS, sep="/")
  write.fasta(ContS, names(ContS), file.out = Dir_FnameS )

  # Write out to std out put
  system(paste("printf", '"', " NumContigs = ", numL, "\n", '"', sep=" "))
  system(paste("printf", '"', "SumContigLength = ", SumLenL, "\n", '"', sep=" "))
  system(paste("printf", '"', "MaxContigLength = ", maxL, "\n", '"', sep=" "))
  system(paste("printf", '"', "Contigs N50 = ", N50L, "\n", '"', sep=" "))
  system(paste("printf", '"', "Contigs L50 = ", L50L, "\n\n", '"', sep=" "))
  system(paste("printf", '"', "NumScaffolds = ", numS, "\n", '"', sep=" "))
  system(paste("printf", '"', "SumScaffoldLength = ", SumLenS, "\n", '"', sep=" "))
  system(paste("printf", '"', "MaxScaffoldLength = ", maxS, "\n", '"', sep=" "))
  system(paste("printf", '"', "Scaffolds N50 = ", N50S, "\n", '"', sep=" "))
  system(paste("printf", '"', "Scaffolds L50 = ", L50S, "\n\n", '"', sep=" "))

}


