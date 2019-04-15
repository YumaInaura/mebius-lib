
use strict;
package main;
use Mebius::BBS::Basic;

#-----------------------------------------------------------
# 設定
#-----------------------------------------------------------

sub init_start_main{


our $moto = "main";
#$head_link1 = 0;
our $head_link2 = 0;
our $nosearch_mode = 1;

	if(defined(&init_option_main)){
		init_option_main();
	}

}

#-----------------------------------------------------------
# モード振り分け
#-----------------------------------------------------------

sub start_main{

my($param) = Mebius::query_single_param();
my $mode = $param->{'mode'};
my $tail = $param->{'tail'};
my($submode1) = split(/-/,$mode);
my($init_directory) = Mebius::BaseInitDirectory();
my $login = new Mebius::Login;
my $bbs_thread = new Mebius::BBS::Thread;

# スクリプト定義
our $script = "/_main/";

my($flag);

	if(Mebius::alocal_judge() || our $server_domain eq "mb2.jp"){ $flag = 1; }

	if($tail eq "xml"){
			if($mode =~ /^bbs_sitemap_index$/ && $flag){ $bbs_thread->sitemap_index_view(2006);

			} elsif($mode =~ /^bbs_sitemap_([0-9]+)$/ && $flag){
				my $times = new Mebius::Time;
				my $status = new Mebius::Status;
				my $year = $1;
				my $year_start_time = $times->year_to_localtime_start($year);
				my $year_end_time = $times->year_to_localtime_end($year); 
				my $data_group = shift || $status->fetchrow_main_table([ ["content_typeA","=","bbs"] , ["content_typeB","=","thread"] , ["deleted_flag","<>",1] , ["content_create_time",">=",$year_start_time] , ["content_create_time","<=",$year_end_time]  ],{ Debug => 0 });
				$bbs_thread->sitemap_view_per_year($year,$data_group);

			}	else{ &error("ページが存在しません。[basemain]"); }

	} else{

			if($submode1 =~ /^(allsearch|maxres|newres|newthread|newsupport|newpaint|newtag|rankspt|rankgold|ranksilver|rankpv|rankspv|allpost|editmemo|echeck|other)$/){ require "${init_directory}part_newlist.pl"; &main_newlist(); }
			elsif($submode1 eq "msc"){ require "${init_directory}main_msc.pl"; &main_msc(); }
			elsif($submode1 eq "admins" && $flag){ require "${init_directory}main_admins.pl"; &main_admins(); }
			elsif($mode eq "my" || $mode eq "settings"){ require "${init_directory}main_mypage.pl"; &main_mypage(); }
			elsif($submode1 eq "tag"){ require "${init_directory}main_tag.pl"; &do_tag; }
			elsif($mode eq "repairurl"){ require "${init_directory}main_repairurl.pl"; &main_repairurl(); }
			#elsif($mode eq "mylist"){ require "${init_directory}part_mylist.pl"; &bbs_mylist(); }
			elsif($submode1 eq "vresedit"){ require "${init_directory}main_vresedit.pl"; &main_vresedit(); }
			elsif($mode eq "index"){ require "${init_directory}main_index.pl"; &main_index(); }
			elsif($mode eq "" && $flag){ require "${init_directory}main_top.pl"; &main_top(); }

			elsif($submode1 eq "error"){ require "${init_directory}main_errorpage.pl"; &main_errorpage(); }
			# 間違ったURLをリダイレクト
			elsif($mode eq "kindex"){ Mebius::Redirect(301,"/"); }
			elsif($mode eq "login_form"){ $login->login_form_view(); }
			elsif($mode eq "login"){ $login->login(); }
			elsif($mode eq "loout_form"){ $login->logout_form_view(); }
			elsif($mode eq "logout"){ $login->logout(); }
			elsif($mode eq "hole"){ require "${init_directory}main_hole.pl"; Mebius::Hole::Start(); }
			elsif($submode1 eq "pallet"){ require "${init_directory}main_pallet.pl"; Mebius::Pallet::Start(); }
			#elsif($mode eq "alive"){ require "${init_directory}main_alive.pl"; Mebius::ServerAlive(); }
			elsif($mode eq "address"){ require "${init_directory}part_cermail.pl"; Mebius::Email::StartAddressForm(); }
			elsif($submode1 eq "history"){ require "${init_directory}part_history.pl"; Mebius::BBS::HistoryIndex(undef,$main::submode2,$main::submode3); }
			elsif($submode1 eq "past"){ require "${init_directory}part_pastindex.pl"; Mebius::BBS::PastIndexView("All-BBS-view"); }
			elsif($mode eq "mailform"){ require "${init_directory}main_mailform.pl"; Mebius::MailForm::Start(); }
			elsif($mode eq "report_view"){ Mebius::Report::report_view(); }
			elsif($mode eq "category"){ Mebius::BBS::Category->index_view(); }
			elsif($mode eq "report_control"){ Mebius::Report::report_control(); }
			else{ &error("ページが存在しません。[basemain] $mode"); }

	}

exit;

}


1;



1;
