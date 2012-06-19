use strict;
use warnings;
use Talk;
use TalkTutorial;
use IntroToPDL;
use IntroToPGPrima;
use Prima::Buttons;

#############################
# Build the talk-picker tab #
#############################

# Main tab container:
my ($action_container, $tab_number) = REPL::create_new_tab('Choose Talk', Widget =>
	pack => { fill => 'both', expand => 1},
);

# Title
$action_container->insert(Label =>
	text => "David Mertens' YAPC::NA 2012 talks",
	valignment => ta::Middle,
	alignment => ta::Center,
	place => {
		x => 0, relwidth => 1,
		rely => 0.5, relheight => 0.5,
		anchor => 'sw',
	},
	font => { size => 32 },
);

# REPL/talk-navigation tutorial button
$action_container->insert(Button =>
	text => 'REPL/Talk Tutorial',
	onClick => sub {
		Talk::clear_talk();
		tutorial;
		t::g(0);
		REPL::goto_page(1);
	},
	place => {
		x => 0, relwidth => 0.333,
		rely => 0, relheight => 0.5,
		anchor => 'sw',
	},
);

# Intro to PDL button
$action_container->insert(Button =>
	text => 'Intro to PDL',
	onClick => sub {
		Talk::clear_talk();
		intro_to_pdl;
		t::g(0);
		REPL::goto_page(1);
	},
	place => {
		relx => 0.333, relwidth => 0.333,
		rely => 0, relheight => 0.5,
		anchor => 'sw',
	},
);

# Intro to PDL::Graphics::Prima button
$action_container->insert(Button =>
	text => 'Intro to PDL::Graphics::Prima',
	onClick => sub {
		Talk::clear_talk();
		pdl_graphics_prima;
		t::g(0);
		REPL::goto_page(1);
	},
	place => {
		relx => 0.666, relwidth => 0.333,
		rely => 0, relheight => 0.5,
		anchor => 'sw',
	},
);

###################
# Select this tab #
###################
scale_fonts(1.4);
REPL::goto_page($tab_number);
