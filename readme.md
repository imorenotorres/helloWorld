This tookbox should serve to explore speech segmentation algorithms
from a linguistic perspective. 

# 1. Motivation 

The main motivation to develop this tookbox is explore how humans
segment speech. We believe that understanding the effects of the
different segmentaion stratedis might be valuable to  address various research questions,
including:

1. Language variation. For instance:
   * do speakers from different dialects/languages segment speech identically?
   * do we segment speech identically in all circumstances?
   
2. Related with language acquisition:
   * do children / adults segment speech identically or as Nittrouer and colleagues have proposed children use larger segments (see Nittrouer, 2004)? 

3. Related with clinical linguistics: 
   * are segmentation strategies disrupted in speech and language processing pathologies?
   * if the answer to the above question is yes, are segmentation errors the source or the consequence of other speech processing problems? 

# 2. Basic structure of the system and flowchart

The system has two main components:
 * A set of speech segmenters
 * A set of segmenter evaluators

The speech segmenters include (to date: 2nd Jun 18)
  * Lee and Cho (2016) brain inspired algorithm
  * A fixed frame segmenter 

The segmenters evaluator should quantify to what extent a specific segmentation is 
successful. The  evaluator implemented to date: 2nd Jun 18) is:
   * Euclidean distance (as used by Lee and Cho, 2016). 

We expect to add more segmenters and evaluators if the authorities 
provide funding to pay our Matlab programmer. 

This is the basic flowchart of the program (Salvador)
