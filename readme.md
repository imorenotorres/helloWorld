Speech segmenter is a 

# 1. Motivation 

Our aim is to develop a tookbox that can be used to explore the impact of how differente segmentation approaches. We expect that it will serve as a linguistic reserch tool, and that it will be valuable to  address research questions in various areas:

1. Language variation
   * do speakers from different dialects/languages segment speech identically?
   * do we segment speech identically in all circumstances?
   * is language change related with speech segmentation?
   
2. Related with language acquisition:
   * do children / adults segment speech identically or as Nittrouer and colleagues have proposed children use larger segments (see Nittrouer, 2004)? 

3. Related with clinical linguistics: 
   * are segmentation strategies disrupted in speech and language processing pathologies?
   * if the answer to the above question is yes, are segmentation errors the source or the consequence of other speech processing problems? 
   * do cochlear implant and normally hearing listeners segment speech identically?

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
