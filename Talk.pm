use strict;
use warnings;

=head1 NAME

App::Prima::REPL::Talk - a presentation extension to App::Prima::REPL

=head1 NOT OFFICIAL

This is my first cut at a presentation module built on top of App::Prima::REPL.
It is far from complete, and even the documentation is imperfect and
incomplete. This module is included in this project precisely so that
the slides that I wrote for Introduction to PDL and Introduction to
PDL::Graphics::Prima can be displayed on others' machine.

=cut

package Talk;
use Prima qw(Label MsgBox);

=head1 VERSION

This documentation is for version 0.01.

=cut

our $VERSION = 0.01;
$VERSION = eval $VERSION;

=head1 SYNOPSIS

In your F<prima-repl.initrc.pl> file, you should have something like this:

 use App::Prima::REPL::Talk;
 
 # Add slides in the order you want them to appear
 title('App::Prima::REPL::Talk', 'by David Mertens');
 
 slide('Simple Slides contain text, code, picture',
     text => 'A single, full-page text element'
 );
 
 slide('Two-column slides contain a left and a right',
     left  => text => 'Text on the left',
     right => code => 'my $code',
 );
 
 slide('Split a slide with a top and bottom',
     top    => text => 'My top-text',
     bottom => code => 'my $code',
 );
 
 my $picture = load_picture();
 slide('Split a colum with a top and a botom',
     left  => text => 'Text on the left',
     right => top    => code    => 'my $code',
              bottom => picture => $picture,
 );
 
 # A code/plot combo; re-running the code modifies the plot
 my ($code, $plot) = create_code_and_plot('my $code');
 slide('Code-and-plot combos are pretty awesome',
     left => text =>
         'Specify the location of the code; the plot will
          take the other option.
          
          When you call PDL::Graphics::Prima::Simple plot
          commands from the code section, it runs those plot
          commands on the plot widget rather than creating a
          new tab.',
     right => code_and_plot => top => q{
         use PDL;
         my $x = sequence(100)/10;
         plot($x, $x->sin); 
         },
 );

To run the talk, navigate to your talk directory and, from the command line,
run L<prima-repl>:

 > cd my/talk/directory
 > prima-repl

Then, from the input line during the talk, you can navigate with the
following commands:

 t::n       # next slide
 t::p       # previous slide
 t::f       # first slide
 t::l       # last slide
 t::g(3)    # go to slide #3
 t::g(1)    #       first slide
 t::g(0)    #       also first slide
 t::g(-1)   #       last slide
 t::g(-2)   #       second-to-last slide
 t::S1      # go to Section 1
 t::S2      #       Section 2 (etc)

=cut

use Exporter 'import';
our @EXPORT = qw(slide title set_footer scale_fonts custom_slide);

####################
# Slide Navigation #
####################

my @slide_funcs;
my $current_slide = -1;

# go to slide
sub t::g {
	my $slide = shift;
	
	# Set a sane default for strings/undefined values:
	{
		no warnings 'numeric';
		$slide -= 1;
	}
	# make negative slides, as well as extreme slides, work
	$slide += @slide_funcs if $slide < -1;
	$slide = 0 if $slide < 0;
	$slide = $#slide_funcs if $slide > $#slide_funcs;
	
	# Set the current slide to the requested slide:
	$current_slide = $slide;
	$slide_funcs[$current_slide]->();
}

sub t::n {
	t::g $current_slide + 2;
}

sub t::p {
	t::g($current_slide);
}

sub t::f {
	t::g(1);
}

sub t::l {
	t::g(-1);
}


############################################################################
# Name         : clear_talk
# Purpose      : removes all slides from the current talk array (@slide_funcs)
# Parameters   : none
# Returns      : none
# Side-effects : empties @slide_funcs, sets the current slide to -1, and
#              : destroys all currently allocated widgets
############################################################################

sub clear_talk {
	clean_slide();
	$current_slide = -1;
	@slide_funcs = ();
}

################
# The Talk tab #
################

$::text_font_size = 10;

# Main tab container:
my ($main_container, $tab_number) = main::REPL()->create_new_tab('Talk', Widget =>
	pack => { fill => 'both', expand => 1},
	backColor => cl::White,
);

#######################
# Page title handling #
#######################

$::page_title_font_size = 2.4 * $::text_font_size;

# Title label, which goes on the top of the page
my $title_label = $main_container->insert(Label =>
	place => {
		x => 0, relwidth => 1,
		rely => 1, y => -45, height => 35,
		anchor => 'sw',
	},
	valignment => ta::Top,
	alignment => ta::Center,
	backColor => cl::White,
);

sub page_title {
	my $title_text = shift;
	$title_label->text($title_text);
	$title_label->font->size($::page_title_font_size);
	$title_label->place(
		height => $::page_title_font_size * 1.8,
		y => -10 - $::page_title_font_size * 1.8,
	);
}

###################
# Footer handling #
###################

my $footer_container = $main_container->insert(Widget =>
	place => {
		x => 5, width => -10, relwidth => 1,
		y => 5, height => 30,
		anchor => 'sw',
	},
	backColor => cl::White,
);

my %footer_parts;
my ($l_off, $footer_width) = (0, 1/3);
my @footer_align = (ta::Left, ta::Center, ta::Right);
for my $position (qw(left center right)) {
	$footer_parts{$position} = $footer_container->insert(Label =>
		place => {
			relx => $l_off, relwidth => $footer_width,
			y => 0, relheight => 1,
			anchor => 'sw',
		},
		backColor => cl::White,
		valignment => ta::Middle,
		alignment => shift (@footer_align),
	);
	$l_off += $footer_width;
}

sub set_footer {
	for my $position (qw(left center)) {
		$footer_parts{$position}->text(shift @_);
	}
}

sub footer_visible {
	my $is_visible = shift;
	for my $widget (values %footer_parts) {
		$widget->visible($is_visible);
		$widget->font->size($::footer_font_size);
		$footer_container->place( height => 10 + $::footer_font_size * 3/2);
	}
	# update the page number
	$footer_parts{right}->text(
		($current_slide + 1) . ' / ' . scalar(@slide_funcs)
	);
}

######################
# Font size handling #
######################

$::editor_font_size = $::text_font_size;
$::footer_font_size = $::text_font_size;
$::title_font_size = $::text_font_size * 3.6;
sub scale_fonts {
	my $factor = shift;
	$factor =~ /^[\d.]+$/
		or return main::REPL()->warn("scale_fonts wants a real number");
	
	# Update all the font sizes
	$::text_font_size *= $factor;
	$::editor_font_size *= $factor;
	$::page_title_font_size *= $factor;
	$::footer_font_size *= $factor;
	$::title_font_size *= $factor;
	
	# Re-render the page
	$slide_funcs[$current_slide]->() if @slide_funcs;
}

########################
# Main slide container #
########################

# Main content container, which contains the table of contents (eventually)
# and the slide material
my $content_container = $main_container->insert(Widget =>
	place => { 
		x => 0, relwidth => 1,
		y => 35, height => -85, relheight => 1,
		anchor => 'sw',
	},
	backColor => cl::White,
);

our $slide_container = $content_container->insert(Widget =>
	place => { 
		x => 0, relwidth => 1,
		y => 0, relheight => 1,
		anchor => 'sw',
	},
	backColor => cl::White,
);

#####################################
# Functions for building the pieces #
#####################################

# Keeps track of all the elements added to the slide that must be
# removed when we move on to the next slide.
our @to_remove;
my $plot_widget;

############################################################################
# Name         : make_and_place
# Purpose      : creates a widget of the given class using the specified
#              : placement
# Parameters   : $class_name, args => $for, place => 'list'
# Returns      : widget
# Side-effects : adds the returned widget to the remove list
############################################################################

sub make_and_place {
	my ($class, %place_args) = @_;
	my $widget = $slide_container->insert($class => place => \%place_args);
	push @to_remove, $widget;
	return $widget;
}

############################################################################
# Name         : make_and_place_editor
# Purpose      : creates a fully endowed editor using the specified placement
# Parameters   : args => $for, place => 'list'
# Returns      : editor widget
# Side-effects : adds the editor widget to the remove list and makes the
#              : editor the REPL's default change widget
############################################################################

sub make_and_place_editor {
	my %place_args = @_;
	my $editor = make_and_place(Edit => %place_args);
	main::REPL()->endow_editor_widget($editor);
	main::REPL()->change_default_widget($tab_number, $editor);
	$editor->font->size($::editor_font_size);
	return $editor;
}

############################################################################
# Name         : build_place_args
# Purpose      : builds the place args for a given sequence of place strings
# Parameters   : @place_args
# Returns      : key => value pairs suitable for place key
# Side-effects : none
# Notes        : This function properly handles the whole string of place
#              : arguments as they accumulate. Thus, if you throw the
#              : following arguments at build_place_args:
#              :   'right', 'top', 'bottom', 'left', 'bottom', 'top'
#              : it will return placement suitable for the upper-left corner
############################################################################

my %default_place_args = (
	anchor => 'sw',
	x => 10, relx => 0,
	width => -20, relwidth => 1,
	y => 10, rely => 0,
	height => -20, relheight => 1,
);
my %modifications_for = (
	top    => [ rely => 0.5, relheight => 0.5],
	bottom => [ rely => 0,   relheight => 0.5],
	left   => [ relx => 0,   relwidth  => 0.5],
	right  => [ relx => 0.5, relwidth  => 0.5],
);
my %name_for_primary_split_next = qw(
	top    bottom
	bottom top
	left   right
	right  left
);

sub build_place_args {
	my @place_list = @_;
	
	# Run through the placement list and infer the location
	my %place_args = %default_place_args;
	my $primary_split_next = '';
	for my $place_spec (@place_list) {
		
		# Reset the args when we move to the other half of the primary split
		%place_args = %default_place_args
			if $primary_split_next eq $place_spec;
		
		# Set the primary_split_next
		$primary_split_next = $name_for_primary_split_next{$place_spec}
			unless $primary_split_next;
		
		# Modify the place args based on the modifications appropriate for
		# the current place_spec
		%place_args = (%place_args, @{$modifications_for{$place_spec}});
	}
	return %place_args;
}

############################################################################
# Name         : render_code_and_plot
# Purpose      : renders a linked code+plot pair
# Parameters   : $code_text, args => $for, editor => 'place list'
# Returns      : editor widget
# Side-effects : adds the editor widget to the remove list
############################################################################

sub render_code_and_plot {
	my ($code_text, @place_list) = @_;
	
	# NiceSlice hack
	$code_text =~ s/use\s+PDL::NiceSlice/use PDL::NiceSlice/g;
		
	# Build the code editor
	my $editor = make_and_place_editor(build_place_args(@place_list));
	$editor->text($code_text);
	
	# Create a subroutine for CTRL-Enter that overrides the plot() command
	push @place_list, $name_for_primary_split_next{$place_list[-1]};
	my %plot_place_hash = build_place_args(@place_list);
	my $run_code_and_plot = sub {
		# Override calls to P::G::P::Simple::plot()
		no warnings 'redefine';
		local *main::plot = local *PDL::Graphics::Prima::Simple::plot = sub {
			# Destroy the plot widget, if it refers to a legitimate object
			eval {$plot_widget->destroy};
			# Create a new plot with the specified constructor
			$plot_widget = 	$slide_container->insert(Plot =>
				@_, place => \%plot_place_hash
			);
		};
		
		# fix print statements so they create pop-ups
		my $to_eval = $editor->text;
		$to_eval =~ s/print /\$TALK_TO_PRINT .= join '', /g;
		
		# eval it!
		main::my_eval("my \$TALK_TO_PRINT = '';\n#line 1 \"text-editor\"
		$to_eval
		Prima::MsgBox::message(\$TALK_TO_PRINT) if \$TALK_TO_PRINT;
		");

		# If error, give a little message pop-up with the trouble:
		if ($@) {
			my $message = $@;
			Prima::MsgBox::message($message, mb::Error);
			$@ = '';
		}
	};
	
	# Update the keyboard accelerator for the editor
	$editor->accelTable->insert([
		# Ctrl-Enter runs the file
		  ['CtrlReturn', '', kb::Return 	| km::Ctrl,  $run_code_and_plot	]
		, ['CtrlEnter', '', kb::Enter  	| km::Ctrl,  $run_code_and_plot	]
		]
		, ''
		, 0
	);
	
	# Render the plot
	$run_code_and_plot->();
}

############################################################################
# Name         : clean_slide
# Purpose      : destroys all widgets that were added to the slide
# Parameters   : none
# Returns      : nothing
# Side-effects : empties @to_remove, destroys the widgets in the list, and
#              : destroys $plot_widget (but does not undefine it)
############################################################################

sub clean_slide {
	# Remove all current widgets
	main::REPL()->change_default_widget($tab_number, main::REPL()->inline);
	eval {$plot_widget->destroy};
	while (@to_remove) {
		my $widget = pop @to_remove;
		$widget->destroy;
	}
	
	# Scale the main interaction window in light of any font changes
	$content_container->place(
		y => $footer_container->height + 5,
		height => -10 - $footer_container->height - $title_label->height,
	);
}

############################################################################
# Name         : render_slide
# Purpose      : renders a slide according to a slide arg list
# Parameters   : see Synopsis
# Returns      : nothing
# Side-effects : calls functions that modify @to_remove and $plot_widget
############################################################################

my %image_cache;
sub render_slide {
	my @args = @_;
	my @place_list;
	while(@args) {
		my $arg = shift @args;
		if (exists $modifications_for{$arg}) {
			# Pull out placement arguments
			push @place_list, $arg;
		}
		elsif ($arg eq 'code_and_plot') {
			# handle code and plot directive
			my ($code_location, $code_text) = splice(@args, 0, 2);
			render_code_and_plot(remove_text_indent($code_text)
					, @place_list, $code_location);
		}
		elsif ($arg eq 'text') {
			my $text = shift @args;
			my $label
				= make_and_place('Label', build_place_args(@place_list));
			$label->text(remove_text_indent($text));
			$label->font->size($::text_font_size);
			#render_text($text, build_place_args(@place_list));
		}
		elsif ($arg eq 'code') {
			my $code_text = shift @args;
			my $editor = make_and_place_editor(build_place_args(@place_list));
			$editor->text(remove_text_indent($code_text));
			main::REPL()->change_default_widget($tab_number, $editor);
		}
		elsif ($arg eq 'image') {
			my $image_filename = shift @args;
			my $image_widget = make_and_place('Widget', build_place_args(@place_list));
			
			# Ensure the image is already in the cache
			$image_cache{$image_filename}
				||= Prima::Image->load($image_filename) or do {
					main::REPL()->warn("Unable to open image file $image_filename");
					next;
				};
			my $image = $image_cache{$image_filename};
			# Set the widget's draw operation to draw a scaled version of
			# the image:
			my $image_aspect_ratio = $image->width / $image->height;
			$image_widget->onPaint(sub {
				my ($width, $height) = $image_widget->size;
				my $dest_aspect_ratio = $width / $height;
				my ($x, $y, $dest_width, $dest_height) = (0, 0, $width, $height);
				if ($dest_aspect_ratio > $image_aspect_ratio) {
					# target is fatter than the image, so the height will be
					# the full extent while the width will be calculated
					$dest_width = $image_aspect_ratio * $dest_height;
					$x = ($width - $dest_width) / 2;
				}
				else {
					# target is skinnier than the image, so the width will be
					# the full extent while the height will be calculated
					$dest_height = $dest_width / $image_aspect_ratio;
					$y = ($height - $dest_height) / 2;
				}
				$image_widget->clear;
				$image_widget->stretch_image(
					$x, $y, $dest_width, $dest_height, $image);
			});
			$image_widget->backColor(cl::White);
		}
		else {
			main::REPL()->warn("Unknown slide construction option $arg");
		}
	}
}

############################################################################
# Name         : slide
# Purpose      : creates a slide with the different elements
# Parameters   : See synopsis
# Returns      : nothing
# Side-effects : adds the specified slide to the @slide_funcs list
# Notes        : the generated function modifies the remove list
############################################################################

sub slide {
	my ($title_text, @args) = @_;
	push @slide_funcs, sub {
		clean_slide;
		page_title($title_text);
		render_slide(@args);
		footer_visible(1);
	};
}


############################################################################
# Name         : custom_slide
# Purpose      : pushes a custom slide callback onto the slide deck
# Parameters   : the subroutine reference to call
# Returns      : nothing
# Side-effects : adds the specified slide callback to the @slide_funcs list
# Notes        : the generated function must clean the slide (call
#              : clean_slide) and place all widgets onto the @to_remove list
############################################################################

sub custom_slide {
	push @slide_funcs, $_[0];
}

############################################################################
# Name         : title
# Purpose      : creates a title slide with a title and subtitle
# Parameters   : $title, $subtitle
# Returns      : nothing
# Side-effects : adds the specified title slide to the @slide_funcs list
# Notes        : the generated function modifies the remove list
#              : you can have as many title slides in a talk as you wish
############################################################################

sub title {
	my ($title, $subtitle) = @_;
	push @slide_funcs, sub {
		clean_slide;
		
		# Blank header/footer
		page_title('');
		footer_visible(0);
		
		# Manually add title and subtitle widgets
		push @to_remove, $slide_container->insert(Label =>
			place => {
				x => 0, relwidth => 1,
				y => 5, rely => 0.5, relheight => 0.5,
				anchor => 'sw',
			},
			valignment => ta::Bottom,
			alignment  => ta::Center,
			font => { size => $::title_font_size },
			text => $title,
		);
		push @to_remove, $slide_container->insert(Label =>
			place => {
				x => 0, relwidth => 1,
				y => 0, relheight => 0.5, height => -1,
				anchor => 'sw',
			},
			valignment => ta::Top,
			alignment  => ta::Center,
			font => { size => $::title_font_size / 2 },
			text => $subtitle,
		);
	};
}

############################################################################
# Name         : remove_text_indent
# Purpose      : removes the initial indentation from a string of text
# Parameters   : $text
# Returns      : cleaned text
# Side-effects : none
############################################################################

sub remove_text_indent {
	my $text = shift;
	
	# Remove leading newline
	$text =~ s/^\s*\n//;
	
	# Figure out and remove the text indentation
	my $indentation;
	if ($text =~ /^(\s+)/) {
		$indentation = $1;
	}
	elsif ($text =~ /^[^\n]+\n(\s+)/) {
		$indentation = $1;
	}
	$text =~ s/^$indentation//gm if $indentation;
	
	# Remove trailing spaces
	$text =~ s/\s+$//;
	
	return $text;
}

1;
