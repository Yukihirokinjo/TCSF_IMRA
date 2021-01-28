##
## ContigsEdgeExtract.R
##

## R script for Draft genome finishing
if(!require(seqinr)) install.packages("seqinr")
library(seqinr)

args         <- commandArgs(trailingOnly=T)
input.fasta  <- args[1]

InCont<-read.fasta(input.fasta, forceDNAtolower = F)
file.create("tmp_ContigsEdge.fasta")

for(i in 1:length(InCont)){

  #object initialize
  Itr    <- numeric();
  StartL <- numeric();
  EndL   <- numeric();
  StartR <- numeric();
  EndR   <- numeric();
  NameL  <- character(); 
  NameR  <- character(); 
  FragL  <- character();        
  FragR  <- character();        

  Itr<-length(InCont[[i]]);

  if( Itr > 5000){
    StartL <- as.numeric(1);
    EndL   <- as.numeric(1 + 2000);
    StartR <- as.numeric(Itr - 2000);
    EndR   <- as.numeric(Itr);
  }else{
    StartL <- as.numeric(1);
    EndL   <- round(as.numeric(1 + (Itr * 0.5)));
    StartR <- round(as.numeric(Itr - (Itr * 0.5)));
    EndR   <- as.numeric(Itr);
  }

  NameL  <- paste(names(InCont[i]), "L", sep=""); 
  NameR  <- paste(names(InCont[i]), "R", sep=""); 

  FragL <- getFrag(InCont[[i]], StartL, EndL);
  FragR <- getFrag(InCont[[i]], StartR, EndR);

  write.fasta(FragL, NameL, file.out="tmp_ContigsEdge.fasta", open = "a");
  write.fasta(FragR, NameR, file.out="tmp_ContigsEdge.fasta", open = "a");

}


