# This tookbox should serve to explore speech segmenting algorithms
# from a linguistic perspective. 

##################
# 1. Motivation###
##################

# The main motivation to develop this tookbox is explore how humans
# segment speech. We believe that understanding the effects of the
# different segmentaion stratedis might be valuable to  address various research questions,
# including:

# 1) philological ones (e.g. do speakers from different dialects/languages
# segment speech identically. 
# 2) Related with language acquisition (do children / adults segment  
# speech ientically (see Nittrouer, 2004)?) 
# 3) Related with clinical linguistics: are segmentation strategies disrupted in the 
# presence of speech and language processing pathologies?

######################################
# 2. Basic structure of the system ###
######################################
# The system has two main components:
# - A set of speech segmenters
# - A set of segmenter evaluators
#
# The speech segmenters include (to date: 2nd Jun 18)
# - Lee and Cho (2016) brain inspired algorithm
# - A fixed frame segmenter 
#
# The segmenters evaluator should quantify to what extent a specific segmentation is 
# successful. The  evaluators implemented to date: 2nd Jun 18) include:
# - Euclidean distance (as used by Lee and Cho, 29016). 
# - (in preparation): acoustic feature informativeness
# 
# We expect to add more segmenters and evaluators if the authorities 
# provide funding to pay our Matlab programmer.  

