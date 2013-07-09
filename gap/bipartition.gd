############################################################################
##
#W  bipartition.gd
#Y  Copyright (C) 2011-13                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareCategory("IsBipartition", IsMultiplicativeElementWithOne and
 IsAssociativeElementWithAction);
DeclareCategoryCollections("IsBipartition");

DeclareGlobalFunction("BipartitionNC");
DeclareGlobalFunction("TransverseBlocksLookup");

DeclareSynonym("IsBipartitionSemigroup", IsSemigroup and
IsBipartitionCollection);

DeclareAttribute("DegreeOfBipartition", IsBipartition);
DeclareAttribute("RankOfBipartition", IsBipartition);
DeclareAttribute("NrBlocks", IsBipartition);
DeclareAttribute("NrLeftBlocks", IsBipartition);
DeclareAttribute("LeftBlocks", IsBipartition);
DeclareAttribute("NrRightBlocks", IsBipartition);
DeclareAttribute("RightBlocks", IsBipartition);
DeclareAttribute("ExtRepBipartition", IsBipartition);

DeclareAttribute("LeftProjection", IsBipartition);
DeclareAttribute("RightProjection", IsBipartition);
DeclareOperation("InverseOp", [IsBipartition]);
DeclareOperation("RandomBipartition", [IsPosInt]);

DeclareGlobalFunction("OnRightBlocks");
DeclareGlobalFunction("OnLeftBlocks");
DeclareGlobalFunction("ExtRepOfBlocks");
DeclareGlobalFunction("BlocksByExtRep");
DeclareGlobalFunction("RankOfBlocks");
DeclareGlobalFunction("DegreeOfBlocks");

DeclareOperation("IdentityBipartition", [IsPosInt]);
DeclareOperation("BipartitionByIntRepNC", [IsList]);
DeclareOperation("BipartitionByIntRep", [IsList]);

DeclareOperation("AsBipartition", [IsPerm, IsPosInt]);
DeclareOperation("AsBipartition", [IsTransformation]);
DeclareOperation("AsBipartition", [IsPartialPerm, IsPosInt]);
DeclareAttribute("AsTransformationNC", IsBipartition);

DeclareProperty("IsTransBipartition", IsBipartition);
DeclareProperty("IsPermBipartition", IsBipartition);
DeclareProperty("IsPartialPermBipartition", IsBipartition);




#old

#DeclareAttribute("DegreeOfBipartitionSemigroup", IsBipartitionSemigroup);
#DeclareAttribute("DegreeOfBipartitionCollection", IsBipartitionCollection);
#DeclareAttribute("RightSignedPartition", IsBipartition);
#DeclareAttribute("LeftSignedPartition", IsBipartition);
#DeclareProperty("IsBipartitionSemigroupGreensClass", IsGreensClass);
#DeclareOperation("OnRightSignedPartition", [IsList, IsBipartition]);
#DeclareOperation("OnLeftSignedPartition", [IsList, IsBipartition]);
#DeclareOperation("RankOfBipartition", [IsBipartition]) ;
#
#DeclareGlobalFunction("INV_SIGNED_PART_BIPART");
