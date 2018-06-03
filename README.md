# This tookbox should serve to explore speech segmenting algorithms
# from a linguistic perspective. The system has two main components:
# - A set of speech segmenters
# - A set of segmenter evaluators
#
# The speech segmenters include (to date: 2nd Jun 18)
# - Lee and Cho (2016) brain inspired algorithm
# - A fixed frame segmenter 
#
# The segmenters evaluator should quantify to what extent a specific segmentation is 
# succesful. The  evaluators implemented to date: 2nd Jun 18) include:
# - Euclidean distance (as used by Lee and Cho, 29016). 
# - (in preparation): acoustic feature informativeness
# 
# We expect to add more segmenters and evaluators if the authorities 
# provide some funding 
# 
# The main motivation to develop this tookbox is explore how humans
# segment speech