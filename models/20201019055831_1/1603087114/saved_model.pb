×
-ä,

ArgMax

input"T
	dimension"Tidx
output"output_type"!
Ttype:
2	
"
Tidxtype0:
2	"
output_typetype0	:
2	
ø
AsString

input"T

output"
Ttype:
2		
"
	precisionint’’’’’’’’’"

scientificbool( "
shortestbool( "
widthint’’’’’’’’’"
fillstring 
B
AssignVariableOp
resource
value"dtype"
dtypetype

BoostedTreesBucketize
float_values*num_features#
bucket_boundaries*num_features
buckets*num_features"
num_featuresint(
h
BoostedTreesCreateEnsemble
tree_ensemble_handle
stamp_token	
tree_ensemble_serialized

(BoostedTreesCreateQuantileStreamResource#
quantile_stream_resource_handle
epsilon
num_streams	"
max_elementsint 
m
BoostedTreesDeserializeEnsemble
tree_ensemble_handle
stamp_token	
tree_ensemble_serialized
k
$BoostedTreesEnsembleResourceHandleOp
resource"
	containerstring "
shared_namestring 
­
BoostedTreesPredict
tree_ensemble_handle0
bucketized_features*num_bucketized_features

logits""
num_bucketized_featuresint(0"
logits_dimensionint

-BoostedTreesQuantileStreamResourceDeserialize#
quantile_stream_resource_handle"
bucket_boundaries*num_streams"
num_streamsint(0

5BoostedTreesQuantileStreamResourceGetBucketBoundaries#
quantile_stream_resource_handle#
bucket_boundaries*num_features"
num_featuresint(
q
*BoostedTreesQuantileStreamResourceHandleOp
resource"
	containerstring "
shared_namestring 
k
BoostedTreesSerializeEnsemble
tree_ensemble_handle
stamp_token	
tree_ensemble_serialized
N
Cast	
x"SrcT	
y"DstT"
SrcTtype"
DstTtype"
Truncatebool( 
h
ConcatV2
values"T*N
axis"Tidx
output"T"
Nint(0"	
Ttype"
Tidxtype0:
2	
8
Const
output"dtype"
valuetensor"
dtypetype
W

ExpandDims

input"T
dim"Tdim
output"T"	
Ttype"
Tdimtype0:
2	
”
HashTableV2
table_handle"
	containerstring "
shared_namestring "!
use_node_name_sharingbool( "
	key_dtypetype"
value_dtypetype
.
Identity

input"T
output"T"	
Ttype
T
!IsBoostedTreesEnsembleInitialized
tree_ensemble_handle
is_initialized

m
/IsBoostedTreesQuantileStreamResourceInitialized#
quantile_stream_resource_handle
is_initialized

w
LookupTableFindV2
table_handle
keys"Tin
default_value"Tout
values"Tout"
Tintype"
Touttype
b
LookupTableImportV2
table_handle
keys"Tin
values"Tout"
Tintype"
Touttype
e
MergeV2Checkpoints
checkpoint_prefixes
destination_prefix"
delete_old_dirsbool(

NoOp

OneHot
indices"TI	
depth
on_value"T
	off_value"T
output"T"
axisint’’’’’’’’’"	
Ttype"
TItype0	:
2	
M
Pack
values"T*N
output"T"
Nint(0"	
Ttype"
axisint 

ParseExampleV2

serialized	
names
sparse_keys

dense_keys
ragged_keys
dense_defaults2Tdense
sparse_indices	*
num_sparse
sparse_values2sparse_types
sparse_shapes	*
num_sparse
dense_values2Tdense#
ragged_values2ragged_value_types'
ragged_row_splits2ragged_split_types"
Tdense
list(type)(:
2	"

num_sparseint("%
sparse_types
list(type)(:
2	"+
ragged_value_types
list(type)(:
2	"*
ragged_split_types
list(type)(:
2	"
dense_shapeslist(shape)(
C
Placeholder
output"dtype"
dtypetype"
shapeshape:
X
PlaceholderWithDefault
input"dtype
output"dtype"
dtypetype"
shapeshape
b
Range
start"Tidx
limit"Tidx
delta"Tidx
output"Tidx"
Tidxtype0:

2	
@
ReadVariableOp
resource
value"dtype"
dtypetype
>
RealDiv
x"T
y"T
z"T"
Ttype:
2	
o
	RestoreV2

prefix
tensor_names
shape_and_slices
tensors2dtypes"
dtypes
list(type)(0
l
SaveV2

prefix
tensor_names
shape_and_slices
tensors2dtypes"
dtypes
list(type)(0
?
Select
	condition

t"T
e"T
output"T"	
Ttype
P
Shape

input"T
output"out_type"	
Ttype"
out_typetype0:
2	
H
ShardedFilename
basename	
shard

num_shards
filename
0
Sigmoid
x"T
y"T"
Ttype:

2
9
Softmax
logits"T
softmax"T"
Ttype:
2
¼
SparseToDense
sparse_indices"Tindices
output_shape"Tindices
sparse_values"T
default_value"T

dense"T"
validate_indicesbool("	
Ttype"
Tindicestype:
2	
@
StaticRegexFullMatch	
input

output
"
patternstring
ö
StridedSlice

input"T
begin"Index
end"Index
strides"Index
output"T"	
Ttype"
Indextype:
2	"

begin_maskint "
end_maskint "
ellipsis_maskint "
new_axis_maskint "
shrink_axis_maskint 
N

StringJoin
inputs*N

output"
Nint(0"
	separatorstring 
;
Sub
x"T
y"T
z"T"
Ttype:
2	

Sum

input"T
reduction_indices"Tidx
output"T"
	keep_dimsbool( " 
Ttype:
2	"
Tidxtype0:
2	
c
Tile

input"T
	multiples"
Tmultiples
output"T"	
Ttype"

Tmultiplestype0:
2	
P
Unpack

value"T
output"T*num"
numint("	
Ttype"
axisint 

VarHandleOp
resource"
	containerstring "
shared_namestring "
dtypetype"
shapeshape"#
allowed_deviceslist(string)
 
9
VarIsInitializedOp
resource
is_initialized

&
	ZerosLike
x"T
y"T"	
Ttype"serve*2.3.02v2.3.0-rc2-23-gb36436b0878÷Ū

global_step/Initializer/zerosConst*
_class
loc:@global_step*
_output_shapes
: *
dtype0	*
value	B	 R 

global_stepVarHandleOp*
_class
loc:@global_step*
_output_shapes
: *
dtype0	*
shape: *
shared_nameglobal_step
g
,global_step/IsInitialized/VarIsInitializedOpVarIsInitializedOpglobal_step*
_output_shapes
: 
_
global_step/AssignAssignVariableOpglobal_stepglobal_step/Initializer/zeros*
dtype0	
c
global_step/Read/ReadVariableOpReadVariableOpglobal_step*
_output_shapes
: *
dtype0	
o
input_example_tensorPlaceholder*#
_output_shapes
:’’’’’’’’’*
dtype0*
shape:’’’’’’’’’
U
ParseExample/ConstConst*
_output_shapes
: *
dtype0*
valueB 
W
ParseExample/Const_1Const*
_output_shapes
: *
dtype0*
valueB 
W
ParseExample/Const_2Const*
_output_shapes
: *
dtype0*
valueB 
W
ParseExample/Const_3Const*
_output_shapes
: *
dtype0*
valueB 
W
ParseExample/Const_4Const*
_output_shapes
: *
dtype0*
valueB 
W
ParseExample/Const_5Const*
_output_shapes
: *
dtype0*
valueB 
W
ParseExample/Const_6Const*
_output_shapes
: *
dtype0*
valueB 
W
ParseExample/Const_7Const*
_output_shapes
: *
dtype0*
valueB 
W
ParseExample/Const_8Const*
_output_shapes
: *
dtype0*
valueB 
W
ParseExample/Const_9Const*
_output_shapes
: *
dtype0*
valueB 
d
!ParseExample/ParseExampleV2/namesConst*
_output_shapes
: *
dtype0*
valueB 
{
'ParseExample/ParseExampleV2/sparse_keysConst*
_output_shapes
:*
dtype0* 
valueBBJOBBREASON
³
&ParseExample/ParseExampleV2/dense_keysConst*
_output_shapes
:
*
dtype0*Y
valuePBN
BCLAGEBCLNOBDEBTINCBDELINQBDEROGBLOANBMORTDUEBNINQBVALUEBYOJ
j
'ParseExample/ParseExampleV2/ragged_keysConst*
_output_shapes
: *
dtype0*
valueB 
©
ParseExample/ParseExampleV2ParseExampleV2input_example_tensor!ParseExample/ParseExampleV2/names'ParseExample/ParseExampleV2/sparse_keys&ParseExample/ParseExampleV2/dense_keys'ParseExample/ParseExampleV2/ragged_keysParseExample/ConstParseExample/Const_1ParseExample/Const_2ParseExample/Const_3ParseExample/Const_4ParseExample/Const_5ParseExample/Const_6ParseExample/Const_7ParseExample/Const_8ParseExample/Const_9*
Tdense
2
*¤
_output_shapes
:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:::’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’*N
dense_shapes>
<::::::::::*

num_sparse*
ragged_split_types
 *
ragged_value_types
 *
sparse_types
2
n
boosted_trees$BoostedTreesEnsembleResourceHandleOp*
_output_shapes
: *
shared_nameboosted_trees/
v
4boosted_trees/BoostedTreesCreateEnsemble/stamp_tokenConst*
_output_shapes
: *
dtype0	*
value	B	 R 

Aboosted_trees/BoostedTreesCreateEnsemble/tree_ensemble_serializedConst*
_output_shapes
: *
dtype0*
valueB B 
Ī
(boosted_trees/BoostedTreesCreateEnsembleBoostedTreesCreateEnsembleboosted_trees4boosted_trees/BoostedTreesCreateEnsemble/stamp_tokenAboosted_trees/BoostedTreesCreateEnsemble/tree_ensemble_serialized
{
/boosted_trees/IsBoostedTreesEnsembleInitialized!IsBoostedTreesEnsembleInitializedboosted_trees*
_output_shapes
: 
u
+boosted_trees/BoostedTreesSerializeEnsembleBoostedTreesSerializeEnsembleboosted_trees*
_output_shapes
: : 

!boosted_trees/QuantileAccumulator*BoostedTreesQuantileStreamResourceHandleOp*
_output_shapes
: *3
shared_name$"boosted_trees/QuantileAccumulator/

Rboosted_trees/QuantileAccumulator/BoostedTreesCreateQuantileStreamResource/epsilonConst*
_output_shapes
: *
dtype0*
valueB
 *
×#<

Vboosted_trees/QuantileAccumulator/BoostedTreesCreateQuantileStreamResource/num_streamsConst*
_output_shapes
: *
dtype0	*
value	B	 R

Å
Jboosted_trees/QuantileAccumulator/BoostedTreesCreateQuantileStreamResource(BoostedTreesCreateQuantileStreamResource!boosted_trees/QuantileAccumulatorRboosted_trees/QuantileAccumulator/BoostedTreesCreateQuantileStreamResource/epsilonVboosted_trees/QuantileAccumulator/BoostedTreesCreateQuantileStreamResource/num_streams
æ
Qboosted_trees/QuantileAccumulator/IsBoostedTreesQuantileStreamResourceInitialized/IsBoostedTreesQuantileStreamResourceInitialized!boosted_trees/QuantileAccumulator*
_output_shapes
: 
ā
Cboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries5BoostedTreesQuantileStreamResourceGetBucketBoundaries!boosted_trees/QuantileAccumulator*¬
_output_shapes
:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’*
num_features

ä
Eboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries_15BoostedTreesQuantileStreamResourceGetBucketBoundaries!boosted_trees/QuantileAccumulator*¬
_output_shapes
:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’*
num_features

q
,boosted_trees/transform_features/CLAGE/sub/yConst*
_output_shapes
: *
dtype0*
valueB
 *NÖ3C
°
*boosted_trees/transform_features/CLAGE/subSubParseExample/ParseExampleV2:6,boosted_trees/transform_features/CLAGE/sub/y*
T0*'
_output_shapes
:’’’’’’’’’
u
0boosted_trees/transform_features/CLAGE/truediv/yConst*
_output_shapes
: *
dtype0*
valueB
 *	Ę¬B
É
.boosted_trees/transform_features/CLAGE/truedivRealDiv*boosted_trees/transform_features/CLAGE/sub0boosted_trees/transform_features/CLAGE/truediv/y*
T0*'
_output_shapes
:’’’’’’’’’
p
+boosted_trees/transform_features/CLNO/sub/yConst*
_output_shapes
: *
dtype0*
valueB
 *śqŖA
®
)boosted_trees/transform_features/CLNO/subSubParseExample/ParseExampleV2:7+boosted_trees/transform_features/CLNO/sub/y*
T0*'
_output_shapes
:’’’’’’’’’
t
/boosted_trees/transform_features/CLNO/truediv/yConst*
_output_shapes
: *
dtype0*
valueB
 *H "A
Ę
-boosted_trees/transform_features/CLNO/truedivRealDiv)boosted_trees/transform_features/CLNO/sub/boosted_trees/transform_features/CLNO/truediv/y*
T0*'
_output_shapes
:’’’’’’’’’
s
.boosted_trees/transform_features/DEBTINC/sub/yConst*
_output_shapes
: *
dtype0*
valueB
 *ÅGB
“
,boosted_trees/transform_features/DEBTINC/subSubParseExample/ParseExampleV2:8.boosted_trees/transform_features/DEBTINC/sub/y*
T0*'
_output_shapes
:’’’’’’’’’
w
2boosted_trees/transform_features/DEBTINC/truediv/yConst*
_output_shapes
: *
dtype0*
valueB
 *rA
Ļ
0boosted_trees/transform_features/DEBTINC/truedivRealDiv,boosted_trees/transform_features/DEBTINC/sub2boosted_trees/transform_features/DEBTINC/truediv/y*
T0*'
_output_shapes
:’’’’’’’’’
r
-boosted_trees/transform_features/DELINQ/sub/yConst*
_output_shapes
: *
dtype0*
valueB
 *q«č>
²
+boosted_trees/transform_features/DELINQ/subSubParseExample/ParseExampleV2:9-boosted_trees/transform_features/DELINQ/sub/y*
T0*'
_output_shapes
:’’’’’’’’’
v
1boosted_trees/transform_features/DELINQ/truediv/yConst*
_output_shapes
: *
dtype0*
valueB
 *?
Ģ
/boosted_trees/transform_features/DELINQ/truedivRealDiv+boosted_trees/transform_features/DELINQ/sub1boosted_trees/transform_features/DELINQ/truediv/y*
T0*'
_output_shapes
:’’’’’’’’’
q
,boosted_trees/transform_features/DEROG/sub/yConst*
_output_shapes
: *
dtype0*
valueB
 *Ķ³>
±
*boosted_trees/transform_features/DEROG/subSubParseExample/ParseExampleV2:10,boosted_trees/transform_features/DEROG/sub/y*
T0*'
_output_shapes
:’’’’’’’’’
u
0boosted_trees/transform_features/DEROG/truediv/yConst*
_output_shapes
: *
dtype0*
valueB
 *1ŗV?
É
.boosted_trees/transform_features/DEROG/truedivRealDiv*boosted_trees/transform_features/DEROG/sub0boosted_trees/transform_features/DEROG/truediv/y*
T0*'
_output_shapes
:’’’’’’’’’
¹
?boosted_trees/transform_features/JOB_indicator/JOB_lookup/ConstConst*
_output_shapes
:*
dtype0*F
value=B;BOtherBSalesBProfExeBOfficeBMgrBSelfBMissing

>boosted_trees/transform_features/JOB_indicator/JOB_lookup/SizeConst*
_output_shapes
: *
dtype0*
value	B :

Eboosted_trees/transform_features/JOB_indicator/JOB_lookup/range/startConst*
_output_shapes
: *
dtype0*
value	B : 

Eboosted_trees/transform_features/JOB_indicator/JOB_lookup/range/deltaConst*
_output_shapes
: *
dtype0*
value	B :
²
?boosted_trees/transform_features/JOB_indicator/JOB_lookup/rangeRangeEboosted_trees/transform_features/JOB_indicator/JOB_lookup/range/start>boosted_trees/transform_features/JOB_indicator/JOB_lookup/SizeEboosted_trees/transform_features/JOB_indicator/JOB_lookup/range/delta*
_output_shapes
:
»
>boosted_trees/transform_features/JOB_indicator/JOB_lookup/CastCast?boosted_trees/transform_features/JOB_indicator/JOB_lookup/range*

DstT0	*

SrcT0*
_output_shapes
:

Jboosted_trees/transform_features/JOB_indicator/JOB_lookup/hash_table/ConstConst*
_output_shapes
: *
dtype0	*
valueB	 R
’’’’’’’’’
Ü
Oboosted_trees/transform_features/JOB_indicator/JOB_lookup/hash_table/hash_tableHashTableV2*
_output_shapes
: *
	key_dtype0*@
shared_name1/hash_table_0fa58e58-fc1a-48bf-b53d-c70aa095578e*
value_dtype0	
ć
cboosted_trees/transform_features/JOB_indicator/JOB_lookup/hash_table/table_init/LookupTableImportV2LookupTableImportV2Oboosted_trees/transform_features/JOB_indicator/JOB_lookup/hash_table/hash_table?boosted_trees/transform_features/JOB_indicator/JOB_lookup/Const>boosted_trees/transform_features/JOB_indicator/JOB_lookup/Cast*	
Tin0*

Tout0	
ß
Rboosted_trees/transform_features/JOB_indicator/hash_table_Lookup/LookupTableFindV2LookupTableFindV2Oboosted_trees/transform_features/JOB_indicator/JOB_lookup/hash_table/hash_tableParseExample/ParseExampleV2:2Jboosted_trees/transform_features/JOB_indicator/JOB_lookup/hash_table/Const*	
Tin0*

Tout0	*#
_output_shapes
:’’’’’’’’’

Jboosted_trees/transform_features/JOB_indicator/SparseToDense/default_valueConst*
_output_shapes
: *
dtype0	*
valueB	 R
’’’’’’’’’
ō
<boosted_trees/transform_features/JOB_indicator/SparseToDenseSparseToDenseParseExample/ParseExampleV2ParseExample/ParseExampleV2:4Rboosted_trees/transform_features/JOB_indicator/hash_table_Lookup/LookupTableFindV2Jboosted_trees/transform_features/JOB_indicator/SparseToDense/default_value*
T0	*
Tindices0	*0
_output_shapes
:’’’’’’’’’’’’’’’’’’

<boosted_trees/transform_features/JOB_indicator/one_hot/ConstConst*
_output_shapes
: *
dtype0*
valueB
 *  ?

>boosted_trees/transform_features/JOB_indicator/one_hot/Const_1Const*
_output_shapes
: *
dtype0*
valueB
 *    
~
<boosted_trees/transform_features/JOB_indicator/one_hot/depthConst*
_output_shapes
: *
dtype0*
value	B :
ł
6boosted_trees/transform_features/JOB_indicator/one_hotOneHot<boosted_trees/transform_features/JOB_indicator/SparseToDense<boosted_trees/transform_features/JOB_indicator/one_hot/depth<boosted_trees/transform_features/JOB_indicator/one_hot/Const>boosted_trees/transform_features/JOB_indicator/one_hot/Const_1*
T0*4
_output_shapes"
 :’’’’’’’’’’’’’’’’’’

Dboosted_trees/transform_features/JOB_indicator/Sum/reduction_indicesConst*
_output_shapes
:*
dtype0*
valueB:
ž’’’’’’’’
é
2boosted_trees/transform_features/JOB_indicator/SumSum6boosted_trees/transform_features/JOB_indicator/one_hotDboosted_trees/transform_features/JOB_indicator/Sum/reduction_indices*
T0*'
_output_shapes
:’’’’’’’’’
p
+boosted_trees/transform_features/LOAN/sub/yConst*
_output_shapes
: *
dtype0*
valueB
 *Ö&F
Æ
)boosted_trees/transform_features/LOAN/subSubParseExample/ParseExampleV2:11+boosted_trees/transform_features/LOAN/sub/y*
T0*'
_output_shapes
:’’’’’’’’’
t
/boosted_trees/transform_features/LOAN/truediv/yConst*
_output_shapes
: *
dtype0*
valueB
 *a.F
Ę
-boosted_trees/transform_features/LOAN/truedivRealDiv)boosted_trees/transform_features/LOAN/sub/boosted_trees/transform_features/LOAN/truediv/y*
T0*'
_output_shapes
:’’’’’’’’’
s
.boosted_trees/transform_features/MORTDUE/sub/yConst*
_output_shapes
: *
dtype0*
valueB
 *ńG
µ
,boosted_trees/transform_features/MORTDUE/subSubParseExample/ParseExampleV2:12.boosted_trees/transform_features/MORTDUE/sub/y*
T0*'
_output_shapes
:’’’’’’’’’
w
2boosted_trees/transform_features/MORTDUE/truediv/yConst*
_output_shapes
: *
dtype0*
valueB
 *J&+G
Ļ
0boosted_trees/transform_features/MORTDUE/truedivRealDiv,boosted_trees/transform_features/MORTDUE/sub2boosted_trees/transform_features/MORTDUE/truediv/y*
T0*'
_output_shapes
:’’’’’’’’’
p
+boosted_trees/transform_features/NINQ/sub/yConst*
_output_shapes
: *
dtype0*
valueB
 *Hm?
Æ
)boosted_trees/transform_features/NINQ/subSubParseExample/ParseExampleV2:13+boosted_trees/transform_features/NINQ/sub/y*
T0*'
_output_shapes
:’’’’’’’’’
t
/boosted_trees/transform_features/NINQ/truediv/yConst*
_output_shapes
: *
dtype0*
valueB
 *Ž?
Ę
-boosted_trees/transform_features/NINQ/truedivRealDiv)boosted_trees/transform_features/NINQ/sub/boosted_trees/transform_features/NINQ/truediv/y*
T0*'
_output_shapes
:’’’’’’’’’
§
Eboosted_trees/transform_features/REASON_indicator/REASON_lookup/ConstConst*
_output_shapes
:*
dtype0*.
value%B#BDebtConBHomeImpBMissing

Dboosted_trees/transform_features/REASON_indicator/REASON_lookup/SizeConst*
_output_shapes
: *
dtype0*
value	B :

Kboosted_trees/transform_features/REASON_indicator/REASON_lookup/range/startConst*
_output_shapes
: *
dtype0*
value	B : 

Kboosted_trees/transform_features/REASON_indicator/REASON_lookup/range/deltaConst*
_output_shapes
: *
dtype0*
value	B :
Ź
Eboosted_trees/transform_features/REASON_indicator/REASON_lookup/rangeRangeKboosted_trees/transform_features/REASON_indicator/REASON_lookup/range/startDboosted_trees/transform_features/REASON_indicator/REASON_lookup/SizeKboosted_trees/transform_features/REASON_indicator/REASON_lookup/range/delta*
_output_shapes
:
Ē
Dboosted_trees/transform_features/REASON_indicator/REASON_lookup/CastCastEboosted_trees/transform_features/REASON_indicator/REASON_lookup/range*

DstT0	*

SrcT0*
_output_shapes
:

Pboosted_trees/transform_features/REASON_indicator/REASON_lookup/hash_table/ConstConst*
_output_shapes
: *
dtype0	*
valueB	 R
’’’’’’’’’
ā
Uboosted_trees/transform_features/REASON_indicator/REASON_lookup/hash_table/hash_tableHashTableV2*
_output_shapes
: *
	key_dtype0*@
shared_name1/hash_table_0c5b0a68-420e-4089-9e43-cfa45bc8ece0*
value_dtype0	
ū
iboosted_trees/transform_features/REASON_indicator/REASON_lookup/hash_table/table_init/LookupTableImportV2LookupTableImportV2Uboosted_trees/transform_features/REASON_indicator/REASON_lookup/hash_table/hash_tableEboosted_trees/transform_features/REASON_indicator/REASON_lookup/ConstDboosted_trees/transform_features/REASON_indicator/REASON_lookup/Cast*	
Tin0*

Tout0	
ī
Uboosted_trees/transform_features/REASON_indicator/hash_table_Lookup/LookupTableFindV2LookupTableFindV2Uboosted_trees/transform_features/REASON_indicator/REASON_lookup/hash_table/hash_tableParseExample/ParseExampleV2:3Pboosted_trees/transform_features/REASON_indicator/REASON_lookup/hash_table/Const*	
Tin0*

Tout0	*#
_output_shapes
:’’’’’’’’’

Mboosted_trees/transform_features/REASON_indicator/SparseToDense/default_valueConst*
_output_shapes
: *
dtype0	*
valueB	 R
’’’’’’’’’
’
?boosted_trees/transform_features/REASON_indicator/SparseToDenseSparseToDenseParseExample/ParseExampleV2:1ParseExample/ParseExampleV2:5Uboosted_trees/transform_features/REASON_indicator/hash_table_Lookup/LookupTableFindV2Mboosted_trees/transform_features/REASON_indicator/SparseToDense/default_value*
T0	*
Tindices0	*0
_output_shapes
:’’’’’’’’’’’’’’’’’’

?boosted_trees/transform_features/REASON_indicator/one_hot/ConstConst*
_output_shapes
: *
dtype0*
valueB
 *  ?

Aboosted_trees/transform_features/REASON_indicator/one_hot/Const_1Const*
_output_shapes
: *
dtype0*
valueB
 *    

?boosted_trees/transform_features/REASON_indicator/one_hot/depthConst*
_output_shapes
: *
dtype0*
value	B :

9boosted_trees/transform_features/REASON_indicator/one_hotOneHot?boosted_trees/transform_features/REASON_indicator/SparseToDense?boosted_trees/transform_features/REASON_indicator/one_hot/depth?boosted_trees/transform_features/REASON_indicator/one_hot/ConstAboosted_trees/transform_features/REASON_indicator/one_hot/Const_1*
T0*4
_output_shapes"
 :’’’’’’’’’’’’’’’’’’

Gboosted_trees/transform_features/REASON_indicator/Sum/reduction_indicesConst*
_output_shapes
:*
dtype0*
valueB:
ž’’’’’’’’
ņ
5boosted_trees/transform_features/REASON_indicator/SumSum9boosted_trees/transform_features/REASON_indicator/one_hotGboosted_trees/transform_features/REASON_indicator/Sum/reduction_indices*
T0*'
_output_shapes
:’’’’’’’’’
q
,boosted_trees/transform_features/VALUE/sub/yConst*
_output_shapes
: *
dtype0*
valueB
 *2ĘG
±
*boosted_trees/transform_features/VALUE/subSubParseExample/ParseExampleV2:14,boosted_trees/transform_features/VALUE/sub/y*
T0*'
_output_shapes
:’’’’’’’’’
u
0boosted_trees/transform_features/VALUE/truediv/yConst*
_output_shapes
: *
dtype0*
valueB
 *[G
É
.boosted_trees/transform_features/VALUE/truedivRealDiv*boosted_trees/transform_features/VALUE/sub0boosted_trees/transform_features/VALUE/truediv/y*
T0*'
_output_shapes
:’’’’’’’’’
o
*boosted_trees/transform_features/YOJ/sub/yConst*
_output_shapes
: *
dtype0*
valueB
 *Ō4A
­
(boosted_trees/transform_features/YOJ/subSubParseExample/ParseExampleV2:15*boosted_trees/transform_features/YOJ/sub/y*
T0*'
_output_shapes
:’’’’’’’’’
s
.boosted_trees/transform_features/YOJ/truediv/yConst*
_output_shapes
: *
dtype0*
valueB
 *ĪĢń@
Ć
,boosted_trees/transform_features/YOJ/truedivRealDiv(boosted_trees/transform_features/YOJ/sub.boosted_trees/transform_features/YOJ/truediv/y*
T0*'
_output_shapes
:’’’’’’’’’

boosted_trees/unstackUnpack.boosted_trees/transform_features/CLAGE/truediv*
T0*#
_output_shapes
:’’’’’’’’’*

axis*	
num
Ó
#boosted_trees/BoostedTreesBucketizeBoostedTreesBucketizeboosted_trees/unstackEboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries_1*#
_output_shapes
:’’’’’’’’’*
num_features
^
boosted_trees/ExpandDims/dimConst*
_output_shapes
: *
dtype0*
value	B :

boosted_trees/ExpandDims
ExpandDims#boosted_trees/BoostedTreesBucketizeboosted_trees/ExpandDims/dim*
T0*'
_output_shapes
:’’’’’’’’’

boosted_trees/unstack_1Unpack-boosted_trees/transform_features/CLNO/truediv*
T0*#
_output_shapes
:’’’’’’’’’*

axis*	
num
Ł
%boosted_trees/BoostedTreesBucketize_1BoostedTreesBucketizeboosted_trees/unstack_1Gboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries_1:1*#
_output_shapes
:’’’’’’’’’*
num_features
`
boosted_trees/ExpandDims_1/dimConst*
_output_shapes
: *
dtype0*
value	B :
”
boosted_trees/ExpandDims_1
ExpandDims%boosted_trees/BoostedTreesBucketize_1boosted_trees/ExpandDims_1/dim*
T0*'
_output_shapes
:’’’’’’’’’

boosted_trees/unstack_2Unpack0boosted_trees/transform_features/DEBTINC/truediv*
T0*#
_output_shapes
:’’’’’’’’’*

axis*	
num
Ł
%boosted_trees/BoostedTreesBucketize_2BoostedTreesBucketizeboosted_trees/unstack_2Gboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries_1:2*#
_output_shapes
:’’’’’’’’’*
num_features
`
boosted_trees/ExpandDims_2/dimConst*
_output_shapes
: *
dtype0*
value	B :
”
boosted_trees/ExpandDims_2
ExpandDims%boosted_trees/BoostedTreesBucketize_2boosted_trees/ExpandDims_2/dim*
T0*'
_output_shapes
:’’’’’’’’’

boosted_trees/unstack_3Unpack/boosted_trees/transform_features/DELINQ/truediv*
T0*#
_output_shapes
:’’’’’’’’’*

axis*	
num
Ł
%boosted_trees/BoostedTreesBucketize_3BoostedTreesBucketizeboosted_trees/unstack_3Gboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries_1:3*#
_output_shapes
:’’’’’’’’’*
num_features
`
boosted_trees/ExpandDims_3/dimConst*
_output_shapes
: *
dtype0*
value	B :
”
boosted_trees/ExpandDims_3
ExpandDims%boosted_trees/BoostedTreesBucketize_3boosted_trees/ExpandDims_3/dim*
T0*'
_output_shapes
:’’’’’’’’’

boosted_trees/unstack_4Unpack.boosted_trees/transform_features/DEROG/truediv*
T0*#
_output_shapes
:’’’’’’’’’*

axis*	
num
Ł
%boosted_trees/BoostedTreesBucketize_4BoostedTreesBucketizeboosted_trees/unstack_4Gboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries_1:4*#
_output_shapes
:’’’’’’’’’*
num_features
`
boosted_trees/ExpandDims_4/dimConst*
_output_shapes
: *
dtype0*
value	B :
”
boosted_trees/ExpandDims_4
ExpandDims%boosted_trees/BoostedTreesBucketize_4boosted_trees/ExpandDims_4/dim*
T0*'
_output_shapes
:’’’’’’’’’

boosted_trees/CastCast2boosted_trees/transform_features/JOB_indicator/Sum*

DstT0*

SrcT0*'
_output_shapes
:’’’’’’’’’
Ō
boosted_trees/unstack_5Unpackboosted_trees/Cast*
T0*}
_output_shapesk
i:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’*

axis*	
num
`
boosted_trees/ExpandDims_5/dimConst*
_output_shapes
: *
dtype0*
value	B :

boosted_trees/ExpandDims_5
ExpandDimsboosted_trees/unstack_5boosted_trees/ExpandDims_5/dim*
T0*'
_output_shapes
:’’’’’’’’’
`
boosted_trees/ExpandDims_6/dimConst*
_output_shapes
: *
dtype0*
value	B :

boosted_trees/ExpandDims_6
ExpandDimsboosted_trees/unstack_5:1boosted_trees/ExpandDims_6/dim*
T0*'
_output_shapes
:’’’’’’’’’
`
boosted_trees/ExpandDims_7/dimConst*
_output_shapes
: *
dtype0*
value	B :

boosted_trees/ExpandDims_7
ExpandDimsboosted_trees/unstack_5:2boosted_trees/ExpandDims_7/dim*
T0*'
_output_shapes
:’’’’’’’’’
`
boosted_trees/ExpandDims_8/dimConst*
_output_shapes
: *
dtype0*
value	B :

boosted_trees/ExpandDims_8
ExpandDimsboosted_trees/unstack_5:3boosted_trees/ExpandDims_8/dim*
T0*'
_output_shapes
:’’’’’’’’’
`
boosted_trees/ExpandDims_9/dimConst*
_output_shapes
: *
dtype0*
value	B :

boosted_trees/ExpandDims_9
ExpandDimsboosted_trees/unstack_5:4boosted_trees/ExpandDims_9/dim*
T0*'
_output_shapes
:’’’’’’’’’
a
boosted_trees/ExpandDims_10/dimConst*
_output_shapes
: *
dtype0*
value	B :

boosted_trees/ExpandDims_10
ExpandDimsboosted_trees/unstack_5:5boosted_trees/ExpandDims_10/dim*
T0*'
_output_shapes
:’’’’’’’’’
a
boosted_trees/ExpandDims_11/dimConst*
_output_shapes
: *
dtype0*
value	B :

boosted_trees/ExpandDims_11
ExpandDimsboosted_trees/unstack_5:6boosted_trees/ExpandDims_11/dim*
T0*'
_output_shapes
:’’’’’’’’’

boosted_trees/unstack_6Unpack-boosted_trees/transform_features/LOAN/truediv*
T0*#
_output_shapes
:’’’’’’’’’*

axis*	
num
Ł
%boosted_trees/BoostedTreesBucketize_5BoostedTreesBucketizeboosted_trees/unstack_6Gboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries_1:5*#
_output_shapes
:’’’’’’’’’*
num_features
a
boosted_trees/ExpandDims_12/dimConst*
_output_shapes
: *
dtype0*
value	B :
£
boosted_trees/ExpandDims_12
ExpandDims%boosted_trees/BoostedTreesBucketize_5boosted_trees/ExpandDims_12/dim*
T0*'
_output_shapes
:’’’’’’’’’

boosted_trees/unstack_7Unpack0boosted_trees/transform_features/MORTDUE/truediv*
T0*#
_output_shapes
:’’’’’’’’’*

axis*	
num
Ł
%boosted_trees/BoostedTreesBucketize_6BoostedTreesBucketizeboosted_trees/unstack_7Gboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries_1:6*#
_output_shapes
:’’’’’’’’’*
num_features
a
boosted_trees/ExpandDims_13/dimConst*
_output_shapes
: *
dtype0*
value	B :
£
boosted_trees/ExpandDims_13
ExpandDims%boosted_trees/BoostedTreesBucketize_6boosted_trees/ExpandDims_13/dim*
T0*'
_output_shapes
:’’’’’’’’’

boosted_trees/unstack_8Unpack-boosted_trees/transform_features/NINQ/truediv*
T0*#
_output_shapes
:’’’’’’’’’*

axis*	
num
Ł
%boosted_trees/BoostedTreesBucketize_7BoostedTreesBucketizeboosted_trees/unstack_8Gboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries_1:7*#
_output_shapes
:’’’’’’’’’*
num_features
a
boosted_trees/ExpandDims_14/dimConst*
_output_shapes
: *
dtype0*
value	B :
£
boosted_trees/ExpandDims_14
ExpandDims%boosted_trees/BoostedTreesBucketize_7boosted_trees/ExpandDims_14/dim*
T0*'
_output_shapes
:’’’’’’’’’

boosted_trees/Cast_1Cast5boosted_trees/transform_features/REASON_indicator/Sum*

DstT0*

SrcT0*'
_output_shapes
:’’’’’’’’’

boosted_trees/unstack_9Unpackboosted_trees/Cast_1*
T0*A
_output_shapes/
-:’’’’’’’’’:’’’’’’’’’:’’’’’’’’’*

axis*	
num
a
boosted_trees/ExpandDims_15/dimConst*
_output_shapes
: *
dtype0*
value	B :

boosted_trees/ExpandDims_15
ExpandDimsboosted_trees/unstack_9boosted_trees/ExpandDims_15/dim*
T0*'
_output_shapes
:’’’’’’’’’
a
boosted_trees/ExpandDims_16/dimConst*
_output_shapes
: *
dtype0*
value	B :

boosted_trees/ExpandDims_16
ExpandDimsboosted_trees/unstack_9:1boosted_trees/ExpandDims_16/dim*
T0*'
_output_shapes
:’’’’’’’’’
a
boosted_trees/ExpandDims_17/dimConst*
_output_shapes
: *
dtype0*
value	B :

boosted_trees/ExpandDims_17
ExpandDimsboosted_trees/unstack_9:2boosted_trees/ExpandDims_17/dim*
T0*'
_output_shapes
:’’’’’’’’’

boosted_trees/unstack_10Unpack.boosted_trees/transform_features/VALUE/truediv*
T0*#
_output_shapes
:’’’’’’’’’*

axis*	
num
Ś
%boosted_trees/BoostedTreesBucketize_8BoostedTreesBucketizeboosted_trees/unstack_10Gboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries_1:8*#
_output_shapes
:’’’’’’’’’*
num_features
a
boosted_trees/ExpandDims_18/dimConst*
_output_shapes
: *
dtype0*
value	B :
£
boosted_trees/ExpandDims_18
ExpandDims%boosted_trees/BoostedTreesBucketize_8boosted_trees/ExpandDims_18/dim*
T0*'
_output_shapes
:’’’’’’’’’

boosted_trees/unstack_11Unpack,boosted_trees/transform_features/YOJ/truediv*
T0*#
_output_shapes
:’’’’’’’’’*

axis*	
num
Ś
%boosted_trees/BoostedTreesBucketize_9BoostedTreesBucketizeboosted_trees/unstack_11Gboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries_1:9*#
_output_shapes
:’’’’’’’’’*
num_features
a
boosted_trees/ExpandDims_19/dimConst*
_output_shapes
: *
dtype0*
value	B :
£
boosted_trees/ExpandDims_19
ExpandDims%boosted_trees/BoostedTreesBucketize_9boosted_trees/ExpandDims_19/dim*
T0*'
_output_shapes
:’’’’’’’’’
ß
!boosted_trees/BoostedTreesPredictBoostedTreesPredictboosted_treesboosted_trees/ExpandDimsboosted_trees/ExpandDims_1boosted_trees/ExpandDims_2boosted_trees/ExpandDims_3boosted_trees/ExpandDims_4boosted_trees/ExpandDims_5boosted_trees/ExpandDims_6boosted_trees/ExpandDims_7boosted_trees/ExpandDims_8boosted_trees/ExpandDims_9boosted_trees/ExpandDims_10boosted_trees/ExpandDims_11boosted_trees/ExpandDims_12boosted_trees/ExpandDims_13boosted_trees/ExpandDims_14boosted_trees/ExpandDims_15boosted_trees/ExpandDims_16boosted_trees/ExpandDims_17boosted_trees/ExpandDims_18boosted_trees/ExpandDims_19*'
_output_shapes
:’’’’’’’’’*
logits_dimension*
num_bucketized_features
|
+boosted_trees/head/predictions/logits/ShapeShape!boosted_trees/BoostedTreesPredict*
T0*
_output_shapes
:

?boosted_trees/head/predictions/logits/assert_rank_at_least/rankConst*
_output_shapes
: *
dtype0*
value	B :
q
iboosted_trees/head/predictions/logits/assert_rank_at_least/assert_type/statically_determined_correct_typeNoOp
b
Zboosted_trees/head/predictions/logits/assert_rank_at_least/static_checks_determined_all_okNoOp

'boosted_trees/head/predictions/logisticSigmoid!boosted_trees/BoostedTreesPredict*
T0*'
_output_shapes
:’’’’’’’’’

)boosted_trees/head/predictions/zeros_like	ZerosLike!boosted_trees/BoostedTreesPredict*
T0*'
_output_shapes
:’’’’’’’’’

4boosted_trees/head/predictions/two_class_logits/axisConst*
_output_shapes
: *
dtype0*
valueB :
’’’’’’’’’
ś
/boosted_trees/head/predictions/two_class_logitsConcatV2)boosted_trees/head/predictions/zeros_like!boosted_trees/BoostedTreesPredict4boosted_trees/head/predictions/two_class_logits/axis*
N*
T0*'
_output_shapes
:’’’’’’’’’

,boosted_trees/head/predictions/probabilitiesSoftmax/boosted_trees/head/predictions/two_class_logits*
T0*'
_output_shapes
:’’’’’’’’’
}
2boosted_trees/head/predictions/class_ids/dimensionConst*
_output_shapes
: *
dtype0*
valueB :
’’’’’’’’’
Å
(boosted_trees/head/predictions/class_idsArgMax/boosted_trees/head/predictions/two_class_logits2boosted_trees/head/predictions/class_ids/dimension*
T0*#
_output_shapes
:’’’’’’’’’
x
-boosted_trees/head/predictions/ExpandDims/dimConst*
_output_shapes
: *
dtype0*
valueB :
’’’’’’’’’
Ā
)boosted_trees/head/predictions/ExpandDims
ExpandDims(boosted_trees/head/predictions/class_ids-boosted_trees/head/predictions/ExpandDims/dim*
T0	*'
_output_shapes
:’’’’’’’’’
u
$boosted_trees/head/predictions/ShapeShape!boosted_trees/BoostedTreesPredict*
T0*
_output_shapes
:
|
2boosted_trees/head/predictions/strided_slice/stackConst*
_output_shapes
:*
dtype0*
valueB: 
~
4boosted_trees/head/predictions/strided_slice/stack_1Const*
_output_shapes
:*
dtype0*
valueB:
~
4boosted_trees/head/predictions/strided_slice/stack_2Const*
_output_shapes
:*
dtype0*
valueB:
Č
,boosted_trees/head/predictions/strided_sliceStridedSlice$boosted_trees/head/predictions/Shape2boosted_trees/head/predictions/strided_slice/stack4boosted_trees/head/predictions/strided_slice/stack_14boosted_trees/head/predictions/strided_slice/stack_2*
Index0*
T0*
_output_shapes
: *
shrink_axis_mask
l
*boosted_trees/head/predictions/range/startConst*
_output_shapes
: *
dtype0*
value	B : 
l
*boosted_trees/head/predictions/range/limitConst*
_output_shapes
: *
dtype0*
value	B :
l
*boosted_trees/head/predictions/range/deltaConst*
_output_shapes
: *
dtype0*
value	B :
Ķ
$boosted_trees/head/predictions/rangeRange*boosted_trees/head/predictions/range/start*boosted_trees/head/predictions/range/limit*boosted_trees/head/predictions/range/delta*
_output_shapes
:
q
/boosted_trees/head/predictions/ExpandDims_1/dimConst*
_output_shapes
: *
dtype0*
value	B : 
¹
+boosted_trees/head/predictions/ExpandDims_1
ExpandDims$boosted_trees/head/predictions/range/boosted_trees/head/predictions/ExpandDims_1/dim*
T0*
_output_shapes

:
q
/boosted_trees/head/predictions/Tile/multiples/1Const*
_output_shapes
: *
dtype0*
value	B :
Ā
-boosted_trees/head/predictions/Tile/multiplesPack,boosted_trees/head/predictions/strided_slice/boosted_trees/head/predictions/Tile/multiples/1*
N*
T0*
_output_shapes
:
¹
#boosted_trees/head/predictions/TileTile+boosted_trees/head/predictions/ExpandDims_1-boosted_trees/head/predictions/Tile/multiples*
T0*'
_output_shapes
:’’’’’’’’’
w
&boosted_trees/head/predictions/Shape_1Shape!boosted_trees/BoostedTreesPredict*
T0*
_output_shapes
:
~
4boosted_trees/head/predictions/strided_slice_1/stackConst*
_output_shapes
:*
dtype0*
valueB: 

6boosted_trees/head/predictions/strided_slice_1/stack_1Const*
_output_shapes
:*
dtype0*
valueB:

6boosted_trees/head/predictions/strided_slice_1/stack_2Const*
_output_shapes
:*
dtype0*
valueB:
Ņ
.boosted_trees/head/predictions/strided_slice_1StridedSlice&boosted_trees/head/predictions/Shape_14boosted_trees/head/predictions/strided_slice_1/stack6boosted_trees/head/predictions/strided_slice_1/stack_16boosted_trees/head/predictions/strided_slice_1/stack_2*
Index0*
T0*
_output_shapes
: *
shrink_axis_mask
n
,boosted_trees/head/predictions/range_1/startConst*
_output_shapes
: *
dtype0*
value	B : 
n
,boosted_trees/head/predictions/range_1/limitConst*
_output_shapes
: *
dtype0*
value	B :
n
,boosted_trees/head/predictions/range_1/deltaConst*
_output_shapes
: *
dtype0*
value	B :
Õ
&boosted_trees/head/predictions/range_1Range,boosted_trees/head/predictions/range_1/start,boosted_trees/head/predictions/range_1/limit,boosted_trees/head/predictions/range_1/delta*
_output_shapes
:

'boosted_trees/head/predictions/AsStringAsString&boosted_trees/head/predictions/range_1*
T0*
_output_shapes
:
q
/boosted_trees/head/predictions/ExpandDims_2/dimConst*
_output_shapes
: *
dtype0*
value	B : 
¼
+boosted_trees/head/predictions/ExpandDims_2
ExpandDims'boosted_trees/head/predictions/AsString/boosted_trees/head/predictions/ExpandDims_2/dim*
T0*
_output_shapes

:
s
1boosted_trees/head/predictions/Tile_1/multiples/1Const*
_output_shapes
: *
dtype0*
value	B :
Č
/boosted_trees/head/predictions/Tile_1/multiplesPack.boosted_trees/head/predictions/strided_slice_11boosted_trees/head/predictions/Tile_1/multiples/1*
N*
T0*
_output_shapes
:
½
%boosted_trees/head/predictions/Tile_1Tile+boosted_trees/head/predictions/ExpandDims_2/boosted_trees/head/predictions/Tile_1/multiples*
T0*'
_output_shapes
:’’’’’’’’’

*boosted_trees/head/predictions/str_classesAsString)boosted_trees/head/predictions/ExpandDims*
T0	*'
_output_shapes
:’’’’’’’’’
t
boosted_trees/head/ShapeShape,boosted_trees/head/predictions/probabilities*
T0*
_output_shapes
:
p
&boosted_trees/head/strided_slice/stackConst*
_output_shapes
:*
dtype0*
valueB: 
r
(boosted_trees/head/strided_slice/stack_1Const*
_output_shapes
:*
dtype0*
valueB:
r
(boosted_trees/head/strided_slice/stack_2Const*
_output_shapes
:*
dtype0*
valueB:

 boosted_trees/head/strided_sliceStridedSliceboosted_trees/head/Shape&boosted_trees/head/strided_slice/stack(boosted_trees/head/strided_slice/stack_1(boosted_trees/head/strided_slice/stack_2*
Index0*
T0*
_output_shapes
: *
shrink_axis_mask
`
boosted_trees/head/range/startConst*
_output_shapes
: *
dtype0*
value	B : 
`
boosted_trees/head/range/limitConst*
_output_shapes
: *
dtype0*
value	B :
`
boosted_trees/head/range/deltaConst*
_output_shapes
: *
dtype0*
value	B :

boosted_trees/head/rangeRangeboosted_trees/head/range/startboosted_trees/head/range/limitboosted_trees/head/range/delta*
_output_shapes
:
f
boosted_trees/head/AsStringAsStringboosted_trees/head/range*
T0*
_output_shapes
:
c
!boosted_trees/head/ExpandDims/dimConst*
_output_shapes
: *
dtype0*
value	B : 

boosted_trees/head/ExpandDims
ExpandDimsboosted_trees/head/AsString!boosted_trees/head/ExpandDims/dim*
T0*
_output_shapes

:
e
#boosted_trees/head/Tile/multiples/1Const*
_output_shapes
: *
dtype0*
value	B :

!boosted_trees/head/Tile/multiplesPack boosted_trees/head/strided_slice#boosted_trees/head/Tile/multiples/1*
N*
T0*
_output_shapes
:

boosted_trees/head/TileTileboosted_trees/head/ExpandDims!boosted_trees/head/Tile/multiples*
T0*'
_output_shapes
:’’’’’’’’’

initNoOp
é
init_all_tablesNoOpd^boosted_trees/transform_features/JOB_indicator/JOB_lookup/hash_table/table_init/LookupTableImportV2j^boosted_trees/transform_features/REASON_indicator/REASON_lookup/hash_table/table_init/LookupTableImportV2

init_1NoOp
4

group_depsNoOp^init^init_1^init_all_tables
Y
save/filename/inputConst*
_output_shapes
: *
dtype0*
valueB Bmodel
n
save/filenamePlaceholderWithDefaultsave/filename/input*
_output_shapes
: *
dtype0*
shape: 
e

save/ConstPlaceholderWithDefaultsave/filename*
_output_shapes
: *
dtype0*
shape: 
{
save/StaticRegexFullMatchStaticRegexFullMatch
save/Const"/device:CPU:**
_output_shapes
: *
pattern
^s3://.*
a
save/Const_1Const"/device:CPU:**
_output_shapes
: *
dtype0*
valueB B.part

save/Const_2Const"/device:CPU:**
_output_shapes
: *
dtype0*<
value3B1 B+_temp_6613554316c14a5bad94605caa9a1954/part
|
save/SelectSelectsave/StaticRegexFullMatchsave/Const_1save/Const_2"/device:CPU:**
T0*
_output_shapes
: 
f
save/StringJoin
StringJoin
save/Constsave/Select"/device:CPU:**
N*
_output_shapes
: 
Q
save/num_shardsConst*
_output_shapes
: *
dtype0*
value	B :
k
save/ShardedFilename/shardConst"/device:CPU:0*
_output_shapes
: *
dtype0*
value	B : 

save/ShardedFilenameShardedFilenamesave/StringJoinsave/ShardedFilename/shardsave/num_shards"/device:CPU:0*
_output_shapes
: 
ė
save/SaveV2/tensor_namesConst"/device:CPU:0*
_output_shapes
:*
dtype0*
valueBB7boosted_trees/QuantileAccumulator:0_bucket_boundaries_0B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_1B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_2B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_3B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_4B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_5B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_6B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_7B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_8B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_9Bboosted_trees:0_stampBboosted_trees:0_serializedBglobal_step

save/SaveV2/shape_and_slicesConst"/device:CPU:0*
_output_shapes
:*
dtype0*-
value$B"B B B B B B B B B B B B B 
Š
save/SaveV2SaveV2save/ShardedFilenamesave/SaveV2/tensor_namessave/SaveV2/shape_and_slicesCboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundariesEboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries:1Eboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries:2Eboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries:3Eboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries:4Eboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries:5Eboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries:6Eboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries:7Eboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries:8Eboosted_trees/BoostedTreesQuantileStreamResourceGetBucketBoundaries:9+boosted_trees/BoostedTreesSerializeEnsemble-boosted_trees/BoostedTreesSerializeEnsemble:1global_step/Read/ReadVariableOp"/device:CPU:0*
dtypes
2		
 
save/control_dependencyIdentitysave/ShardedFilename^save/SaveV2"/device:CPU:0*
T0*'
_class
loc:@save/ShardedFilename*
_output_shapes
: 
 
+save/MergeV2Checkpoints/checkpoint_prefixesPacksave/ShardedFilename^save/control_dependency"/device:CPU:0*
N*
T0*
_output_shapes
:
u
save/MergeV2CheckpointsMergeV2Checkpoints+save/MergeV2Checkpoints/checkpoint_prefixes
save/Const"/device:CPU:0

save/IdentityIdentity
save/Const^save/MergeV2Checkpoints^save/control_dependency"/device:CPU:0*
T0*
_output_shapes
: 
ī
save/RestoreV2/tensor_namesConst"/device:CPU:0*
_output_shapes
:*
dtype0*
valueBB7boosted_trees/QuantileAccumulator:0_bucket_boundaries_0B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_1B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_2B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_3B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_4B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_5B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_6B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_7B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_8B7boosted_trees/QuantileAccumulator:0_bucket_boundaries_9Bboosted_trees:0_stampBboosted_trees:0_serializedBglobal_step

save/RestoreV2/shape_and_slicesConst"/device:CPU:0*
_output_shapes
:*
dtype0*-
value$B"B B B B B B B B B B B B B 
Ū
save/RestoreV2	RestoreV2
save/Constsave/RestoreV2/tensor_namessave/RestoreV2/shape_and_slices"/device:CPU:0*H
_output_shapes6
4:::::::::::::*
dtypes
2		

2save/BoostedTreesQuantileStreamResourceDeserialize-BoostedTreesQuantileStreamResourceDeserialize!boosted_trees/QuantileAccumulatorsave/RestoreV2save/RestoreV2:1save/RestoreV2:2save/RestoreV2:3save/RestoreV2:4save/RestoreV2:5save/RestoreV2:6save/RestoreV2:7save/RestoreV2:8save/RestoreV2:9K^boosted_trees/QuantileAccumulator/BoostedTreesCreateQuantileStreamResource*
num_streams

§
$save/BoostedTreesDeserializeEnsembleBoostedTreesDeserializeEnsembleboosted_treessave/RestoreV2:10save/RestoreV2:11)^boosted_trees/BoostedTreesCreateEnsemble
Q
save/Identity_1Identitysave/RestoreV2:12*
T0	*
_output_shapes
:
T
save/AssignVariableOpAssignVariableOpglobal_stepsave/Identity_1*
dtype0	

save/restore_shardNoOp^save/AssignVariableOp%^save/BoostedTreesDeserializeEnsemble3^save/BoostedTreesQuantileStreamResourceDeserialize
-
save/restore_allNoOp^save/restore_shard"ø<
save/Const:0save/Identity:0save/restore_all (5 @F8"~
global_stepom
k
global_step:0global_step/Assign!global_step/Read/ReadVariableOp:0(2global_step/Initializer/zeros:0H"L
saveable_objects8
6
boosted_trees:0
#boosted_trees/QuantileAccumulator:0"%
saved_model_main_op


group_deps"é
table_initializerÓ
Š
cboosted_trees/transform_features/JOB_indicator/JOB_lookup/hash_table/table_init/LookupTableImportV2
iboosted_trees/transform_features/REASON_indicator/REASON_lookup/hash_table/table_init/LookupTableImportV2"|
	variablesom
k
global_step:0global_step/Assign!global_step/Read/ReadVariableOp:0(2global_step/Initializer/zeros:0H*ó
classificationą
3
inputs)
input_example_tensor:0’’’’’’’’’;
classes0
boosted_trees/head/Tile:0’’’’’’’’’O
scoresE
.boosted_trees/head/predictions/probabilities:0’’’’’’’’’tensorflow/serving/classify*
predictž
5
examples)
input_example_tensor:0’’’’’’’’’M
all_class_ids<
%boosted_trees/head/predictions/Tile:0’’’’’’’’’M
all_classes>
'boosted_trees/head/predictions/Tile_1:0’’’’’’’’’O
	class_idsB
+boosted_trees/head/predictions/ExpandDims:0	’’’’’’’’’N
classesC
,boosted_trees/head/predictions/str_classes:0’’’’’’’’’L
logistic@
)boosted_trees/head/predictions/logistic:0’’’’’’’’’D
logits:
#boosted_trees/BoostedTreesPredict:0’’’’’’’’’V
probabilitiesE
.boosted_trees/head/predictions/probabilities:0’’’’’’’’’tensorflow/serving/predict*­

regression
3
inputs)
input_example_tensor:0’’’’’’’’’K
outputs@
)boosted_trees/head/predictions/logistic:0’’’’’’’’’tensorflow/serving/regress*ō
serving_defaultą
3
inputs)
input_example_tensor:0’’’’’’’’’;
classes0
boosted_trees/head/Tile:0’’’’’’’’’O
scoresE
.boosted_trees/head/predictions/probabilities:0’’’’’’’’’tensorflow/serving/classify