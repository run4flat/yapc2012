use strict;
use warnings;
use Talk;

use charnames ':full';
my $B = "\N{BULLET}";

sub pdl_graphics_prima {

		# Here's the title, along with the footer.
		title("Introduction to the\nPDL::Graphics::Prima", 'by David Mertens');
		set_footer('David Mertens', 'PDL::Graphics::Prima | YAPC 2012');

		slide('Why PDL::Graphics::Prima?',
			text => qq{
				PDL HAS NO OBVIOUS PLOTTING LIBRARY!!
				
				  $B PDL::Graphics::PGPLOT
					- based on FORTRAN library

				  $B PDL::Graphics::PLplot
					- based on C library

				  $B PDL::Graphics::Gnuplot
					- based on external executable
					- slow data transfer between PDL and Gnuplot
			},
		);

		slide('How is PDL::Graphics::Prima different?',
		text => "
		 
		  
		  $B No external dependencies
			 (apart from X11.h or windows.h)

		  $B Provides a plot widget for Prima GUI toolkit

		  $B Widget => build interactive data analysis tools

		  $B Perlish

		  $B Highly configurable (work in progress :-)

		  $B Sane defaults
		");

		slide('Who did what?',
			text => qq{
				Prima
					Cross-platform GUI toolkit
					Written by Dmitry Karasik (and others)
					Actively maintained (by Dmitry)
				
				PDL::Drawing::Prima
					PDL-enlightened Prima drawing operations
					Written by me using PDL::PP
					Not the subject of this talk
				
				PDL::Graphics::Prima
					PDL plotting library
					Written by me in Perl using PDL::Drawing::Prima and Prima
				
				
				
				This talk is about PDL::Graphics::Prima	
			}
		);

		title('PDL::Graphics::Prima
		::Simple',
				'For quick plotting'
		);

		slide('First Example',
			code_and_plot => left => q{
				use strict;
				use warnings;
				use PDL;
				use PDL::Graphics::Prima::Simple;

				my $x = sequence(100)/10;
				my $y = sin($x);

				plot(
					-data => ds::Pair($x, $y),
				);
			}
		);

		slide('Basic Form of a plot() Command',
			left => text => qq{
				Note:
					$B plot() takes key => value pairs
					$B keys with dashes are datasets
					$B keys without dashes are options
					
				Datasets:
					ds::Set
					ds::Pair
					  ds::Func
					ds::Grid
				
				Axes
					$B axis labels
					$B min/max
					$B linear/logarithmic scaling
			},
			right => code => q{
				plot(
					-some_dataset => ds::Pair(
						$x, $y, options...
					),
					-a_grid => ds::Grid(
						$matrix, options...
					),
					
					x => { label => 'Effort' },
					y => { label => 'Payoff' },
				);
			}
		);

		slide('Datasets can take multiple plot types',
			code_and_plot => left => q{
				# Generate some data
				my $x = sequence(10);
				my $y = $x->sqrt;
				
				# Generate some "error" bars
				my $y_err = $y->grandom/3;

				plot(
					-sine => ds::Pair(
						$x,
						$y,
					
						# Combine multiple plotTypes:
						plotTypes => [
							# Error bars (highly configurable)
							ppair::ErrorBars(y_err => $y_err),
							# Squares
							#ppair::Squares,
							# Histogram...?
							#ppair::Histogram
						],
					),
					
					# Also, add some x- and y-labels:
					x => { label => 'Effort' },
					y => { label => 'Payoff' },
				);
			},
		);


		slide('"Inherited" PDL-threaded properties',
			left => text => qq{
				Properties including things like
				  $B colors
				  $B lineWidths
				  $B linePatterns (dashed, dotted, etc)
				  $B others
				
				Shapes have special properties including
				  $B filled
				  $B N_points
				  $B others
				
				$B specified per-point
				$B most specific specificition is used
				$B implemented with PDL::PP, so they're fast
			},
			right => code => q{
				plot(
					-data => ds::Pair($x, $y
						color => $generic_colors,
						plotTypes => [
							ppair::ErrorBars(y_err => $y_err),
							ppair::Histogram,
							ppair::Lines(
								colors => $line_colors,
								thread_like => 'points',
							),
						],
					)
				);
			},
		);

		# Note BUG!!!
		# If I add ppair::Histogram, this croaks with an off-by-one error!

		slide('Properties Example',
			code_and_plot => left => q{
				# Generate some data
				my $x = sequence(20);
				my $y = $x->sqrt;

				# Generate some "error" bars
				my $y_err = $y->grandom/3;

				# And some colors
				my $rainbow = pal::Rainbow->apply($x);
				my $rev_rainbow = pal::Rainbow->apply(-$x);

				plot(
					-sqrt => ds::Pair($x, $y,
						# dataset-wide colors:
						colors => $rev_rainbow,
						plotTypes => [
							# Use the inherited colors:
							ppair::Squares(filled => 1,
								size => 10),
							# plotType-specific colors override:
							ppair::ErrorBars(y_err => $y_err,
								colors => $rainbow,
								lineWidths => 5),
						],
					),
				);
			}
		);

		slide('Data sets: alphabetical order',
			code_and_plot => left => q{
				# Matrix of sin(x*y)
				my $grid_x = sequence(300)/10 + 0.1;
				my $grid_y = zeroes(1, 500)->ylinvals(-5, 5);
				my $matrix = cos($grid_x * $grid_y);
				use PDL::Constants qw(PI);

				plot(
					-data => ds::Grid($matrix,
						x_bounds => [$grid_x->minmax],
						y_bounds => [$grid_y->minmax],
					),
					-curve => ds::Func( sub {
							my $xs = shift;
							return PI / $xs;
						},
						colors => cl::LightRed,
						lineWidths => 3,
					),
					x => {
						label => 'x',
						scaling => sc::Log,
					},
					y => {
						label => 'Results',
					},
				);
			},
		);

		#############
		# Interlude #
		#############
		# And a seguey to ppair::Symbols

		title('Super-simple interface',
				'Plot one-liners (almost)');

		slide('Super-simple function plotting',
			code_and_plot => left => q{
				func_plot 0 => 10, \&PDL::cos;
				#func_plot 0 => 10,
				#		sub { sin(1/$_[0]) };
			},
		);

		slide('Super-simple grid data',
			code_and_plot => left => q{
				# Generate some data
				my $x = sequence(100)/10;
				my $y = sequence(1,100)/10;
				my $matrix = sin($x * $y);
				
				matrix_plot $matrix;
			},
		);

		slide('Super-simple pairwise data',
			code_and_plot => left => q{
				my $x = sequence(100)/10;
				my $y = $x->sin;
				
				line_plot $x, $y;
				#hist_plot $x, $y;
				#circle_plot $x, $y;
				#triangle_plot $x, $y;
				#square_plot $x, $y;
				#diamond_plot $x, $y;
				#X_plot $x, $y;
				#cross_plot $x, $y;
				#asterisk_plot $x, $y;
			},
		);

		##################
		# ppair::Symbols #
		##################

		title('ppair::Symbols', '');

		slide('ppair::Symbols: flexible and powerful.',
			left => text => qq{
				You can specify:
					$B size (radius) in pixels
					$B filled (boolean)
					$B N_points (integer)
						0, 1 = circle
						2 = stick
						3 = triangle or Y
						4 = square, diamond, X, +
						etc
					$B orientation angle (deg)
						can also be 'up', 'left',
						'down', or 'right'
					$B skip (integer) ...
					$B fillWindings (boolean) ...
			},
			right => code => q{
				my $x = sequence(15);
				my $y = sequence(1, 5);

				plot(
					-symbols => ds::Pair($x, $y,
						plotType => ppair::Symbols(
							N_points => $x,
							filled => $y > 0,
				#            skip => $y,
							size => 20,
						),
					),
					
					# Also, add some x- and y-labels:
					x => {
						label => 'Number of points',
						min => -1, max => 15,
					},
					y => {
						label => 'Unfilled/Filled or Skip',
						min => -0.5, max => 4.5,
					},
				);
			}
		);

		slide('ppair::Symbols: flexible and powerful.',
			code_and_plot => right => q{
				my $x = sequence(15);
				my $y = sequence(1, 5);

				plot(
					-symbols => ds::Pair($x, $y,
						plotType => ppair::Symbols(
							N_points => $x,
							filled => $y > 0,
							#skip => $y,
							size => 20,
							#orientation => 10 * $y,
						),
					),
					
					# Also, add some x- and y-labels:
					x => {
						label => 'Number of points',
						min => -1, max => 15,
					},
					y => {
						label => 'Unfilled/Filled or Skip',
						min => -0.5, max => 4.5,
					},
				);
			}
		);

		slide('Combine two ppair::Symbols',
			code_and_plot => left => q{
				# Need to 'use Prima' for named colors

				my $x = sequence(15);
				my $y = sequence(1, 5);

				plot(
					-symbols => ds::Pair($x, $y,
						plotTypes => [
							# Circles
							ppair::Symbols(
								N_points => 0,
								filled => 1,
								colors => cl::Black,
								size => 20,
							),
							# Circumscribed triangles
							ppair::Symbols(
								N_points => 3,
								filled => 1,
								colors => cl::White,
								size => 19,
								skip => 2,
								orientation => 'up',
								fillWindings => 1,
							),
						]
					),
				);
			}
		);

		slide('Many derived types',
			text => qq{
				Many derived types with more or less configurability:

				  $B ppair::Sticks
				  $B ppair::Triangles
				  $B ppair::Squares
				  * ppair::Diamonds
				  $B ppair::Stars
				  $B ppair::Asterisks
					 - ppair::Xs
					 - ppair::Crosses
			},
		);

		#########
		# Color #
		#########

		title('Working with Color', '');

		slide('Remember this colors example?',
			code_and_plot => left => q{
				# Generate some data
				my $x = sequence(20);
				my $y = $x->sqrt;

				# Generate some "error" bars
				my $y_err = $y->grandom/3;

				# And some colors
				my $rainbow = pal::Rainbow->apply($x);
				my $rev_rainbow = pal::Rainbow->apply(-$x);

				plot(
					-sqrt => ds::Pair($x, $y,
						# dataset-wide colors:
						colors => $rev_rainbow,
						plotTypes => [
							# Use the inherited colors:
							ppair::Squares(filled => 1,
								size => 10),
							# plotType-specific colors override:
							ppair::ErrorBars(y_err => $y_err,
								colors => $rainbow,
								lineWidths => 5),
						],
					),
				);
			}
		);

		slide('Many ways to create colors with PDL',
			left => text => qq{
				Different Palettes
				
				  $B pal::Rainbow
				  $B pal::BlackToWhite
				  $B pal::WhiteToBlack
				  $B pal::WhiteToHSV
				  $B pal::BlackToHSV
				  $B pal::HSVRange
			},
			right => text => qq{
				Directly create color values with PDL methods:

				  $B rgb_to_color()
					 - input piddle has shape (3, ...)
					 - output piddle has Prima colors
				  $B hsv_to_rgb()
					 - input and output piddles
					   have shapes (3, ...)
					 - combine with rgb_to_color()
					   to produce Prima colors
				  
				  
				  $B PDL::Graphics::ColorSpace
			}
		);


		####################
		# Work in progress #
		####################

		title('Still a work in progress...', 'i.e. how you can help!');

		slide('Future directions',
			left => text => "
				Really need...

				 $B More plot types for sets and grids
				 $B Annotations
				 $B Error bands
				 $B Some way to display color scales
				 $B Higher quality figure output
				 $B Legends
				 $B Documentation improvements (of course)
				 $B A test suite (thoughts?)
				",
			right => text => qq{
				Wish list...

				 $B Cairo bindings for Prima::Drawable
				 $B Alien::Cairo (already working on it :-)
				 $B Integration with PDL::Graphics::ColorSpace
				 $B Prettier Prima widgets
				 $B A Pony
			}
		);

		slide('Other things that keep me busy',
			left => text => "
				Related projects:

				  $B PDL
				  $B Prima
				  $B PDL::Drawing::Prima
				  $B PDL::Graphics::ColorSpace

				Other Perl projects that keep me busy:

				  $B PDL core hacking
				  $B Numerical regular expression engine
				  $B True JIT-C compiling using libtcc
				  $B Perl + CUDA
				  $B Helping Joel Berger with Alien::Base
				",
			right => text => "
				My Work:
				
				  $B Amaral Lab, Northwestern University
				  
				  $B Ph. D. in Physics
				  $B Time series analysis
				  $B Statistical analysis
				  $B Big Data
			"
		);
}

1;
