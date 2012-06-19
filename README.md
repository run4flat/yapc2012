yapc2012
========

The content of and modules needed to view my slides from YAPC::NA 2012.

Prerequisites
=============

The prerequisite for this talk is App::Prima::REPL and PDL::Graphics::Prima.
Although it is possible in principle to install these modules using CPAN,
I have had trouble getting PDL::Drawing::Prima to index properly. So I 
recommend that you install the following modules using CPAN (or a similar
client):

  cpan Prima PDL App::cpanminus

Then use cpanm to install the following directly from github:

  cpanm http://github.com/run4flat/PDL-Drawing-Prima/tarball/master
  cpanm http://github.com/run4flat/PDL-Graphics-Prima/tarball/master
  cpanm http://github.com/run4flat/App-Prima-REPL/tarball/master

If you run into trouble installing these, feel free to file an Issue on
this github repo: https://github.com/run4flat/yapc2012

Viewing the Talks
=================

Once you have installed these modules, you can view the talks by

  1) chdir'ing into the root of this project
  2) running prima-repl
  3) resizing the window so it's a bit larger, if possible
  4) clicking on the "REPL/Talk Tutorial" button
