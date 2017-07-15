# -*- coding: utf-8 -*-

"""
Given a plot for an episode of a TV series try and identify SxxExx.

  This module was primarily written for use with myth2kodi. The Guide data
  in MythTV database is only as good as the source. Some sources are crap,
  such as the over the air data broadcast by most free-to-air digital 
  stations in Australia. Despite being crap, at least for over the air 
  data in Sydney, they always seem to include a description/plot field.
  In the event that an aired episode included neither an episode subtitle
  nor season and episode number information, this module identifies the
  best matching episode by comparing the Guide Data's plot field to the
  plots available from TheTVDB. Both of which are obtained and provided
  to this module by the myth2kodi bash script.

Originally Written: 2015-12-02

USAGE:
  #Within myth2kodi
  python plot2episode.py -w "$m2kdir" -s "$NewShowName" -p "$Plot" -l "$LogLevel"

REQUIRES:
  PYTHON VERSION >=2.7 (due to use of argparse)
  gensim >= 0.12.3

PROVIDES:

.. moduleauthor:: Stuart A. Knock <stuart.knock@gmail.com>
  
"""

#TODO: Write a function that can get series information from TheTVDB, so 
#   that this module is less reliant on myth2kodi.

import logging
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)
LOG = logging.getLogger(__name__)

# import os.path.expanduser
# import os.path.join

import gensim.models.doc2vec.Doc2Vec as Doc2Vec
import gensim.models.doc2vec.TaggedDocument as TaggedDocument
import gensim.models.doc2vec.TaggedLineDocument as TaggedLineDocument #See the TODO above load_plots.

#TODO: will need Doc2Vec(min_count=1) as our corpus of sentences is tiny...

### Functions for Generating a Model of the Plots for Episodes of a Series ###

#TODO: See, class gensim.models.doc2vec.TaggedLineDocument(source).
#      Can probably replace load_plots(), clean_plots(), plots2docs()
#      with a single function under the assumption that we've cleaned
#      the plots before writing them to file... which isn't a bad idea.
def load_plots(seriesname):
    """
    Loads the plots stored in myth2kodi's database into a list of strings.
    These are the episode plots downloaded from TheTVDB.
    """
    LOG.debug("Calling load_plots() with the following arguments:")
    LOG.debug("seriesname  = %s"%seriesname)

    plots = []
    return plots


def clean_plots(plots):
    """
    Clean up the strings in the plots list, making them acceptable for
    processing by gensim.
    """
    LOG.debug("Calling clean_plots() with the following arguments:")
    LOG.debug("plots  = %s"%plots)

    plots = []
    return plots


def plots2docs(plots):
    """
    Convert the plots list into a list of TaggedDocument objects. The
    list returned by this function is appropriate as the documents 
    parameter passed to Doc2Vec.
    """
    LOG.debug("Calling plots2docs() with the following arguments:")
    LOG.debug("plots  = %s"%plots)

    documents = []
    return documents


def train_model(newplots):
    """
    Integrates any new episode plots for this series into the training
    of the model. At first call for a new series newplots=plots.
    """
    LOG.debug("Calling load_model() with the following arguments:")
    LOG.debug("newplots  = %s"%newplots)
    
    result = []
    return result


def save_model(seriesname):
    """
    Saves a model file based on the plots downloaded from TheTVDB.
    """
    LOG.debug("Calling save_model() with the following arguments:")
    LOG.debug("seriesname  = %s"%seriesname)
    
    result = []
    return result


### Functions for Using a Model of the Plots for Episodes of a Series ###
def load_model(seriesname):
    """
    Loads a model that we previously computed for the series.
    """
    LOG.debug("Calling load_model() with the following arguments:")
    LOG.debug("seriesname  = %s"%seriesname)
    
    result = []
    return result


def closest_match(episodeplot, seriesname):
    """
    For a given plot identify the closest matching episode. Here, the
    episodeplot variable is the plot extracted from MythTV's guide data.
    """
    LOG.debug("Calling closest_match() with the following arguments:")
    LOG.debug("episodeplot= %s"%episodeplot)
    LOG.debug("seriesname= %s"%seriesname)
    #Doc2Vec.most_similar(positive=[], negative=[], topn=1, restrict_vocab=None)
    #If topn is False, most_similar returns the vector of similarity scores.

    return bestmatch, quality




if __name__ == "__main__":

    import argparse

    #Initialise the argument parser
    parser = argparse.ArgumentParser(
    	description="Given a plot for an episode of a TV series try and identify SxxExx.")

    #Define the arguments we accept
    parser.add_argument("-w", "--workingdir",
    	metavar="$m2kdir",
        required=True,
        #default=os.path.join(os.path.expanduser("~"), ".myth2kodi"),
        help="The working directory. For myth2kodi this is the m2kdir variable.")

    parser.add_argument("-s", "--seriesname",
    	metavar="$NewShowName",
        required=True,
        help="The name of the tv-series we're currently considering.")

    parser.add_argument("-p", "--plot",
    	metavar="$Plot",
        help="The plot belonging to the unidentified episode.")
    
    #The loglevel option is set up to map to the LogLevel variable from
    #myth2kodi to the equivalent level for the python logger. The actual
    #mapping is done after the final argument definition.
    parser.add_argument("-l", "--loglevel",
    	metavar="$LogLevel",
        type=int,
        choices=[0, 1, 2, 3],
        default=1, #Just Errors and Warnings.
        help="Set the logging loglevel: 0=ERROR; 1=WARNING; 2=INFO; 3=DEBUG.")

    #Parse the arguments
    args = parser.parse_args()

    #Set the level for Python's logger with input argument loglevel
    loglevelmapping=["ERROR","WARNING","INFO","DEBUG"]
    LOG.setLevel(loglevelmapping[args.loglevel])

    #Debug logging messages about the arguments
    LOG.debug("plot2episode was called with the following arguments:")
    LOG.debug("workingdir: %s"%args.workingdir)
    LOG.debug("seriesname: %s"%args.seriesname)
    LOG.debug("plot: %s"%args.plot)
    LOG.debug("loglevel: %s"%args.loglevel)

#Test working directory exists and we have read/write access to the directory
#if not then argparse.ArgumentParser.exit(status=1, message="Working directory wasn't accessible: %s"%args.workingdir)

#Check that the data for the series is in our working directory 
#if not then argparse.ArgumentParser.exit(status=1, message="The data for %s isn't in our working directory:."%(args.seriesname, args.workingdir))

#For the requested series try loading an existing model
#If starting from an existing model check if there are any new plots available, if so update model training
#If no existing model, generate one from available plots and save it to file for future use

#If we weren't given a plot to identify then bail.
#If we were given a plot to identify, clean it up then call: bestmatch, quality = closest_match(args.plot, args.seriesname)

#return bestmatch and quality by writing them to a file: os.path.join(args.workingdir, args.seriesname, "AbsoluteEpisodeNumberFromPlot.txt")
#perhaps with a format of:
#bestmatch quality args.plot
#appending so that the data remains for subsequent manual verification if there is a problem.

#If all went well exit with exit code 0, so we can meaningfully check the exit code back in the bash script.

