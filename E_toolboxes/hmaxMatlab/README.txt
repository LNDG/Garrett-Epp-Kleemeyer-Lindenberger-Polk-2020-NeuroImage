qqHMAX: Hierarchical Model And X
==============================

HMAX is a hierarchical, shape-based, computational model of visual object recognition in cortex. It summarizes the basic facts of the ventral visual stream, thought to mediate object recognition in cortex.

For more on the theoretical basis of HMAX, please visit <http://maxlab.neuro.georgetown.edu>.

Files
-----

Included are the following files and directories:

- AUTHORS: a list of the project's authors and maintainers.

- LICENSE: the project's license.

- README: this document.

- C1.m: Given an image, this function returns S1 & C1 unit responses.

- C2.m: Given an image, this function returns S1, C1, S2, & C2 unit responses.

- example.m: an example code implementing the full HMAX hierarchy, using the provided universal patch set and the provided example image set. This function will call all the relevant subfunctions of the HMAX-MATLAB implementation.

- initGabor.m: Given orientations and receptive field sizes, this function returns a set of Gabor filters.

- maxFilter.m: Given an image and pooling range, this function returns a matrix of the image's maximum values in each neighborhood defined by the pooling range

- padImage.m: Given an image, padding amount, and padding method, this function returns a padded image. Think of it as padarray operating on only the first 2 dimensions of a 3 dimensional array.

- extractC2forCell.m: Extract all responses for a set of images.

- sumFilter.m: Given an image and pooling range, this function returns an image where each "pixel" represents the sums of the pixel values within the pooling range of the original pixel.

- unpadImage.m: undoes padimage - given an image and padding amount, this function strips padding off an image

- windowedPatchDistance.m: given an image and patch, this function computes the euclidean distance between the patch and all crops of the image of similar size.

- universal_patch_set.mat: a file containing a set of universal patches of 8 different sizes extracted from random natural images. The file also includes the parameters used during the patch-extraction.

- exampleImages directory - a folder containing 10 images from the Labeled Faces in the Wild database (http://vis-www.cs.umass.edu/lfw/).

- exampleImages.mat: a cell array, each cell contains the path to one image located in the exampleImages folder.

- exampleActivations.mat: a file containing c2, bestBands, and bestLocations variables (see C2.m). This is the output of the example.m code. 

Contact
-------

Please direct all questions and bug reports to the project's current maintainer, listed in AUTHORS.

License
-------

See LICENSE
