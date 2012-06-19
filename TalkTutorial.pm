use strict;
use warnings;
use Talk;

use charnames ':full';
my $B = "\N{BULLET}";

sub tutorial {
	
	set_footer('Talk Tutorial', '');
	
	
	# A custom title slide
	custom_slide sub {
		Talk::clean_slide;
		
		# Blank header/footer
		Talk::page_title('');
		Talk::footer_visible(0);
		
		# Add title and first-step widget
		push @Talk::to_remove, $Talk::slide_container->insert(Label =>
			place => {
				x => 0, relwidth => 1,
				y => 5, rely => 0.5, relheight => 0.5,
				anchor => 'sw',
			},
			valignment => ta::Bottom,
			alignment  => ta::Center,
			font => { size => $::title_font_size },
			text => 'Navigating the talks',
		);
		push @Talk::to_remove, $Talk::slide_container->insert(Widget =>
			place => {
				x => 0, relwidth => 1,
				y => 0, relheight => 0.5, height => -1,
				anchor => 'sw',
			},
			font => {
				height => 20,
			},
			backColor => cl::White,
			lineWidth => 3,
			onPaint => sub {
				my ($self, $canvas) = @_;
				$canvas->clear;
				
				# Draw the text
				$canvas->text_out('Type t::n and press Enter', 40, $self->height - 40);
				
				# Draw the arrow
				$canvas->line(100, $self->height - 60, 100, 0);
				$canvas->line(100, 0, 130, 30);
				$canvas->line(100, 0, 70, 30);
			},
		);
	};
	
	slide("That's the command input line",
		text => q{
			prima-repl (this program) is a full Perl Run-Eval-Print-Loop*.
			You enter commands in the command input line, as you just did.
			
			For example, try entering the following command:
			
			  Prima::message('Hello!')
			
			and press Enter.
			
			Good. Now, with the cursor in the command input line, press the
			up key to find the t::n command that you enetered already.
			
			Press Enter to run it.
			
			
			
			
			
			* It doesn't actually print the output, so maybe it should be
			   called a REL: Run-Eval-Loop.
		},
	);

	slide('Navigation Commands',
		text => qq{
			To navigate the talks, you enter commands on the command input line:
			
			  $B t::n     - next slide
			  $B t::p     - previous slide
			  $B t::g(3)  - go to slide 3
			  $B t::g(0)  - go to first slide
			  $B t::g(1)  - also go to first slide
			  $B t::g(-1) - go to second-to-last slide
			
			Change font size
			
			  scale_fonts(\$factor)
			  
			  Font shrinks if \$factor is less than 1.
			  Font grows if \$factor is greater than 1.
			
			You're almost ready to go through the talks, but there's one
			last item: executing large blocks of text.
		},
	);
	
	slide('Executing Code Buffers',
		left => text => qq{
			Shown to the right is a code buffer. You can edit it if you like.
			There are two ways to execute it:
			
			  $B Ctrl-Enter, simple execution
			  $B Ctrl-Shift-Enter, execute and show Output
			
			The first option simply executes your code. Any printed output
			will be sent to the Output tab, but you must select the Output
			tab to see it. This is useful when your code does not print any
			output or when it has side-effects on the current tab, as is the
			case with the plotting code in the talks.
			
			The latter option will switch to the Output tab before executing
			the code, which is handy when your code buffer uses print
			statements, as this code buffer does.
		},
		right => code => q{
			my $vals = sequence(20);
			
			# What's the sum of 0 throuh 19? Math tells me it's
			# n * (n + 1) / 2:
			print "Theory: ", 19 * 20 / 2, "\n";
			
			# Was my math right?
			print "Computation: ", $vals->sum, "\n";
		},
	);
	
	slide('Second-to-last slide',
		text => q{
			Note that the slides for the talks are interactive, and I had
			specific interactions in mind when I wrote them. Right now, the
			interactions are difficult to describe, so it is best if you
			run these slides with a copy of the talk handy.
			
			But the talk's not available online yet! I know. I will work with
			the people at PresentingPerl to get it (and the other YAPC talks)
			online in the next couple of weeks.
			
			In general, if you see commented code, it is best to uncomment it
			in stages to slowly unveil the results.
		}
	);
	
	slide("That's It!",
		text => q{
			You now know the basics for viewing and interacting with the talks.
			To view them, go to the Choose Talk tab and select one of the
			other talks.
			
			To learn more about the prima-repl, press Ctrl-H or type
			
			  help
			
			at the command input line.
			
			Enjoy!
		},
	);
	
}

1;
