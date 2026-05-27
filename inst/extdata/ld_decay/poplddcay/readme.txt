        # For one Population
        perl Plot_OnePop.pl  -inFile   LDdecay.stat.gz  -output  Fig
        # For muti Population                   #  List Format :[Pop.ResultPath  PopID ]
        perl Plot_MutiPop.pl  -inList  Pop.ResultPath.list  -output Fig
