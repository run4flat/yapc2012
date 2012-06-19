use strict;
use warnings;
use Talk;

use charnames ':full';
my $B = "\N{BULLET}";

# These are not strictly necessary, but I'm getting sick of getting the
# warnings for not loading these (and having to execute the particular
# slide where they are defined).
our $m51 = rfits 'm51_raw.fits';
my $background = rfits 'm51_flatfield.fits';
our $m51c = $m51 / $background;
our $rad = sequence(39) * 10 + 5;
our $bright = $rad->ones;			# junk to avoid warnings


sub intro_to_pdl {

		# Here's the title, along with the footer.
		title("Introduction to the\nPerl Data Language", 'by David Mertens');
		set_footer('David Mertens', 'Intro to PDL | YAPC 2012');

		slide('What is PDL?',
			top => image => 'pdl-logo.png',
			bottom =>
				left => text => 'FAST!',
				right => text => 'COMPACT!',
		);

		title('Disclaimer', join ("\n", 
			"Most of the material in this talk is taken from",
			"Karl Glazebrook's introduction chapter to the",
			"PDL::Book.")
		);

		slide('A First Look',
			code_and_plot => left => q{
				use strict;
				use warnings;
				
				# PDL scripts start here
				use PDL;
				
				# matrix_plot() is from
				# PDL::Graphics::Prima::Simple;
				
				matrix_plot(sin(rvals(200,200)+1));
				
				# Uncomment the next code line and press Ctrl-Enter
				# to see what rvals looks like
				#matrix_plot(rvals(200, 200));
			},
		);

		slide('A Look at The Whirlpool Galaxy',
			code_and_plot => left => q{
				# Load Hubble image of M51
				our $m51 = rfits 'm51_raw.fits';
				
				# Plot it
				imag_plot($m51);
				
				# Uncomment the next code line and press Ctrl-Enter
				# to enhance the contrast:
				#imag_plot(log($m51 + $m51->max/1000));
				
				# Try changing the denominator  ^^^^
				# to see how it effects the contrast
			},
		);

		slide('Correcting The Whirlpool Galaxy',
			code_and_plot => left => q{
				# Load the background:
				my $background
					= rfits 'm51_flatfield.fits';
				
				# Look at the background:
				imag_plot($background);
				
				
				
				# UNCOMMENT AND RUN THE NEXT LINES
				# They define $m51c, which is needed in the
				# upcoming slides
				
				# Correct, enhance, plot:
				#our $m51c = $m51 / $background;
				#imag_plot(log($m51c + $m51c->max/300));
			},
		);

		slide('Masking and Slicing',
			code_and_plot => left => '
				our $m51c;
				my $radii = $m51c->rvals;
				my $mask = $radii < 70;
				# fiddle with this  ^^
				matrix_plot($mask);



				my $center = $m51c->copy;
				# Set "outside" to zero
				$center->where($radii > 250) .= 0;
				#imag_plot(log($center + $center->max/300));
								


				use  PDL::NiceSlice;
				my $slice = $m51c(200:400, 150:350);
				#imag_plot(log($slice + $slice->max/300));
			',
		);

		title(join("\n", 	'It is Better',
							'to perform a single operation',
							'on a complex slice'
					),
				join("\n", 'than to perform many operations',
							'on individual elements of a piddle.'
					),
		);

		slide('Concentric Rings from the Whirlpool',
			code_and_plot => left => q{
				# calculate brightness in a ring
				our $m51c;
				# fiddle with these vv
				my $inner_radius  = 40;
				my $outer_radius  = 50;
				my $radii = $m51c->rvals;
				my $ring_mask = ($inner_radius <= $radii)
												&
								($outer_radius > $radii);
				
				my $brightness
					= $m51c->where($ring_mask)->sum;
				#print "From $inner_radius ",
				#	" to $outer_radius, ",
				#	, "total brightness is $brightness";
				
				# Plot the ring (zero-out everything else)
				my $ring = $m51c->copy;
				$ring->where(1 - $ring_mask) .= 0;
				imag_plot(log($ring + $ring->max/300));
			},
		);

		slide('Analyzing The Whirlpool Galaxy Brightness',
			code_and_plot => left => q{
				# calculate brightness in concentric rings
				our $m51c;
				our $rad = sequence(37) * 10 + 5;
				my @brightness;
				for my $inner_rad ($rad->dog) {
					push @brightness, 
						sum($m51c->where(
						   ($inner_rad - 5 <= $m51c->rvals)
											&
						   ($inner_rad + 5 >  $m51c->rvals)
						));
				}
				
				# Building piddles from arrays is easy:
				our $bright = pdl(@brightness);
				
				# Look at the brightness profile
				hist_plot($rad, $bright);
			},
		);

		slide('Analyzing The Whirlpool Galaxy Luminosity',
			code_and_plot => left => q{
				# calculate luminosity in concentric rings
				use PDL::Constants qw(PI);
				our ($bright, $rad);
				my $lum = $bright / PI
					/ (($rad + 5)**2 - ($rad - 5)**2);
				
				# Plot using a logarithmic y axis
				plot(
					-data => ds::Pair($rad, $lum),
					y => {
				#		scaling => sc::Log,
					},
				);
			},
		);

		slide('A Bright Star',
			code_and_plot => left => q{
				use  PDL::NiceSlice;
				
				# View the star
				my $section = our $m51c(337:357,178:198);
				imag_plot (log($section + $section->max/300));
				
				# Look at its luminosity profile
				my $r = rvals $section;
				# Clump first two dimensions
				our $rr  = $r->clump(2);
				our $sec = $section->clump(2);
				#asterisk_plot($rr, $sec);		
			},
		);

		slide('Full-width Half-maximum of the Star',
			code_and_plot => left => q{
				our ($rr, $sec);
				use PDL::Fit::Gaussian;
				my ($peak, $fwhm, $background)
					= fitgauss1dr($rr, $sec); 
				print "peak = $peak, fwhm = $fwhm, ",
					"background = $background";
				
				# Plot the fit against the data
				plot(
					-data => ds::Pair($rr, $sec),
					-fit => ds::Func(sub {
						my $xs = shift;
						return $background
							+ $peak * exp(
								-2.772 *($xs / $fwhm)**2
							);
						},
						colors => cl::LightRed,
						lineWidths => 2,
					),
				#	y => { scaling => sc::Log },
				);
			}
		);

		title('Conclusion', '');

		slide('Resources',
			left => text => qq{
				Reference:
				
				  $B PDL::Book
				  $B pdl.perl.org
				  $B PDL::MATLAB, PDL::Scilab
				  $B PDL::Tutorials
				  $B PDL::Course
					- guided tour through PDL's docs
					  from beginner to expert
				  $B PDL::Modules
					- hand-curated index of PDL's modules
					- may be incomplete or list modules
					  you don't have on your machine
				  $B PDL::Index
					- autogenerated index of PDL's modules
					- only lists modules that are actually
					  installed on your local machine
				},
			right => text => qq{
				Community:
				
				  $B Mailing list is the best resource
					- must be signed-up to send messages
					- perldl\@jach.hawaii.edu is for general PDL stuff
					- pdl-porters\@jach.hawaii.edu is for development
				  $B irc.perl.org#pdl
					- I am run4flat
				
				People:
				
				  $B Chris Marshall - PDL Pumpking
				  $B Karl Glazebrook - creator
				  $B Christian Soeller, Toumas Lukka
					- geniuses (who have moved on)
				  $B Craig DeForest
					- resident threading genius
				  $B and surely others that I've missed...
					 (my apologies)
				},
		);
}

1;
