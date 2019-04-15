
use strict;
use Mebius::SNS::CommentBoad;
use Mebius::SNS::Account;

use Mebius::AllComments;
use Mebius::Newlist;
use Mebius::Report;
use Mebius::Query;

package main;

#-----------------------------------------------------------
# �`�����{��
#-----------------------------------------------------------
sub auth_view_comment{

# �錾
my($select_year,$index,$account,$multi_flag,%account,$index_line,$fookyear);
my($comments_line,$resform,$navi,$h1_line,$year_title,$print);

Mebius::Report::report_mode_junction({ });

# CSS��`
$main::css_text .= qq(
.ctextarea{width:95%;height:35px;}
.cbottun{margin-top:0.5em;}
.clog{font-size:90%;}
.lic{margin-bottom:0.3em;line-height:1.25;}
.deleted{font-size:90%;color:#f00;}
th{text-align:left;padding:0.5em 1.0em 0.5em 0.0em;}
td{padding:0.2em 1.0em 0.5em 0.0em;line-height:1.4;vertical-align:top;}
input.comment{width:12em;}
);

	# �}���`�A�J�E���g�̔���
	if($main::submode2 eq "multi"){
		$multi_flag = 1;
			# �A�J�E���g�́`�܂ł����I�ׂȂ�
			if((split(/,/,$main::submode3)) > 5){ main::error("�A�J�E���g��I�ׂ����𒴂��Ă��邽�߁A�\\���ł��܂���B"); }
	}

	# �A�J�E���g���J��
	if(!$multi_flag){

		(%account) = Mebius::Auth::File("Option Get-friend-status",$main::in{'account'},%main::myaccount);

			# ��\���ݒ�̏ꍇ
			if($account{'ocomment'} eq "3" && !$main::myaccount{'admin_flag'}){
				&error("���̃����o�[�̓`���͔�\\���ݒ肳��Ă��܂��B","401 Unauthorized");
			}

	}

# ���[�U�[�F�w��
#if($account{'color1'}){ $css_text .= qq(h2{background-color:#$account{'color1'};border-color:#$account{'color1'};}); }

	# �i�r�Q�[�V���������N
	if(!$multi_flag){
		my $link2 = "${main::auth_url}$account{'file'}/";
			if($main::aurl_mode){ ($link2) = &aurl($link2); }
		$navi .= qq(<a href="$link2">�v���t�B�[����</a>);
	}

	# �N�x�؂�ւ������N
	if(!$multi_flag){
		($index_line,$fookyear) = auth_viewcomment_get_yearlinks("",$account{'file'},%account);
	}

# �����t�H�[��
my($searchform) = auth_viewcomment_get_form(undef,$account{'file'});

# �`�����e���擾
	if($multi_flag){
		($comments_line) = view_auth_comment("Get-index Index-view Multi-accounts",$main::submode3);
	}
	else{
		($comments_line,$resform) = view_auth_comment("Get-index Index-view",$account{'file'},$fookyear,undef,%account);
	}

	# �^�C�g����` ( �}���`�A�J�E���g )
	if($multi_flag){
		$main::sub_title = "�`���� �R�����g���� - $main::submode3";
	}
	# �^�C�g����` ( ���� )
	else{
		$year_title = qq( ( $fookyear�N ) ) if($main::submode2);
		$main::sub_title = "$account{'name'}�̓`���� $year_title";
		$main::head_link3 = qq(&gt; <a href="$main::auth_url$account{'file'}/">$account{'name'}</a>);
		$main::head_link4 = qq(&gt; �`����);
			if($main::in{'word'} ne ""){ $main::sub_title = "�h$main::in{'word'}�Ō��� - $account{'name'}�̓`���� $year_title"; }
	}


$print .= qq($main::footer_link);

	# ���o���^�O
	if($multi_flag){
		$h1_line = qq(�`���� �F �R�����g���� - $main::submode3</h1>\n);
	}
	else{
		$h1_line = qq(�`���� $year_title : $account{'name'} - $account{'file'}\n);
	}

$print .= qq(<h1$main::kstyle_h1>$h1_line</h1>\n$navi$index_line\n);

# �ᔽ�񍐂ւ̈ړ��{�^��
my($move_to_report_mode_button) = shift_jis(Mebius::Report::move_to_report_mode_button({ url_hash => "#a" , ViewResReportButton => 1 , NotThread => 1  }));
$print .= $move_to_report_mode_button;

	# ���e�t�H�[��
	if(!$multi_flag){
		$print .= qq($searchform);
		$print .= qq(<h2 id="COMMENT-INPUT"$main::kstyle_h2>���e</h2>$resform\n);
	}

$print .= qq(
$comments_line
<br$main::xclose>
$main::footer_link2
);





Mebius::Template::gzip_and_print_all({},$print);

exit;

}

no strict;

#-----------------------------------------------------------
# �N�x�؂�ւ������N���擾
#-----------------------------------------------------------
sub auth_viewcomment_get_yearlinks{

my($type,$file,%account) = @_;
my($index,$file_handler);
our($xclose);

# ���`
if($submode2){ $index .= qq( <a href="$main::auth_url$file/viewcomment">�ŋ�</a> );}
else{ $index .= qq( <span class="red">�ŋ�</span> ); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �R�����g�C���f�b�N�X���J��
open($file_handler,"<","${account_directory}comments/${file}_index_comment.cgi");
	while(<$file_handler>){
	chomp;
	my($year,$month) = split(/<>/);

	my $link = qq($main::auth_url$file/viewcomment-$year);

	if($year eq $submode2){
		$fookyear = $year;
		$index .= qq( <span class="red">$year�N</span> );
		$select_year .= qq( <input type="radio" name="mode" value="viewcomment-$year" checked$xclose>$year�N);
	}
	else{
		$index .= qq( <a href="$link">$year�N</a> );
		$select_year .= qq( <input type="radio" name="mode" value="viewcomment-$year"$xclose>$year�N);
	}


	}
close($file_handler);

# �C���f�b�N�X���`
if($index ne ""){ $index = qq(�@�@���� �F $index); }

return($index,$fookyear);

}


#-----------------------------------------------------------
# �����t�H�[��
#-----------------------------------------------------------
sub auth_viewcomment_get_form{

# �錾
my($type,$account) = @_;
my($line);
our($xclose,$kfontsize_h2);

my $checked1 = $main::parts{'checked'} if(!$fookyear);

$line = qq(
<h2 id="COMMENT-SEARCH"$kfontsize_h2>����</h2>
<form action="$script">
<div>
<input type="hidden" name="account" value="$account"$xclose>
<input type="text" name="word" value="$in{'word'}" class="comment"$xclose>
<input type="submit" value="�`�����猟������"$xclose>
<input type="radio" name="mode" value="viewcomment"$checked1$xclose>�ŋ�
$select_year
<span class="guide">���u�M���v�u�A�J�E���g���v�u�R�����g���e�v���猟�����܂��B</span>
</div>
</form>

);

# ���^�[��
return($line);

}



use strict;

#������������������������������������������������������������
# �`����
#������������������������������������������������������������
sub view_auth_comment{

# �Ǐ���
my($type,$accounts,$year,$maxview,%account) = @_;
my($my_account) = Mebius::my_account();
my($i,$hit,$file,$stop,$form,$flow_flag,@years,$input_years,$control_flag,$text,@index_line,$i_foreach);
my($comments,$del,$account,@accounts,%multi_account,$i_multi_accounts,%multi_background_class,$multi_flag);
my($param) = Mebius::query_single_param();
my($basic_init) = Mebius::basic_init();
my($my_use_device) = Mebius::my_use_device();
my $query = new Mebius::Query;
my $sns_account = new Mebius::SNS::Account;
our($idcheck,$kflag,$xclose,$kfontsize_h2);

	# �ݒ�
	if(!$maxview){ $maxview = 500; }
	if($main::submode3 eq "all"){ $maxview = 5000; }

# CSS��`
#h2#COMMENT,h2#COMMENT-INPUT,#COMMENT-SEARCH{background:#ff9;border-color:#fc7;}
$main::css_text .= qq(
strong.alert{font-size:90%;color:#f00;}
div.shadow{background:#eee;}
div.deleted{background:#fee;color:#999;}
div.comment-next{margin-top:0.5em;text-align:right;}
div.control{text-align:right;}
div.control_submit{text-align:right;margin:0.5em 0em;}
div.dcm{padding:0.5em 0.5em;line-height:1.4;border-bottom:solid 1px #000;}
);

my $comment_boad_url = "$basic_init->{'auth_url'}$account{'id'}/viewcomment#COMMENT";

	# CSS��` ( 2 )
	if($type =~ /Multi-accounts/){
		$main::css_text .= qq(.multi1{background:#fff;}\n);
		$main::css_text .= qq(.multi2{background:#eef;}\n);
		$main::css_text .= qq(.multi3{background:#afa;}\n);
		$main::css_text .= qq(.multi4{background:#ff8;}\n);
		$main::css_text .= qq(.multi5{background:#ddd;}\n);
		$multi_flag = 1;
	}


	# �n�b�V����`
	foreach (split(/,/,$accounts)){
		$i_multi_accounts++;
		$multi_account{$_} = 1;
		$multi_background_class{$_} = "multi$i_multi_accounts";
	}


	# ���ΏۃA�J�E���g��W�J
	foreach $account (split(/,/,$accounts)){

		# �Ǐ���
		my($file,$comment_handler,%account2);

			# ���}���`�A�J�E���g���J��
			if($type =~ /Multi-accounts/){

				(%account2) = Mebius::Auth::File("Option Get-friend-status",$account,%main::myaccount);

					# �`������\���ݒ�ɂȂ��Ă���ꍇ
					if($account2{'ocomment'} eq "3" && !$my_account->{'admin_flag'}){ next; }

			}

			# �A�J�E���g������
			if(Mebius::Auth::AccountName(undef,$account)){ next; }

		# �f�B���N�g����`
		my($account_directory) = Mebius::Auth::account_directory($account);
			if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

			# �t�@�C���؂�ւ�
			if($year){ $file = "${account_directory}comments/${account}_${year}_comment.cgi"; }
			else{ $file = "${account_directory}comments/${account}_comment.cgi"; }

		# �A�J�E���g
		push(@accounts,$account);

		my($comment_boad) = Mebius::SNS::CommentBoad::log_file({ year => $year },$account);

		# �R�����g���J��
		#open($comment_handler,"<",$file);
		#my $top = <$comment_handler> if(!$year); chomp $top;

			# ���J���A�J�E���g�̌��������A�t�@�C����W�J
		#	while(<$comment_handler>){

				# �Ǐ���
		#		my($viewres,$control_box,$trclass,$class);

				chomp;
		#		my($key,$rgtime,$account2,$name,$trip,$id,$comment,$dates,$xip,$res,$deleter,$control_handle2,$res_concept2,$text_color2) = split(/<>/,$_);



		#	}

		#close($comment_handler);
		push @index_line , @{$comment_boad->{'res_data'}} if $comment_boad->{'res_data'};

					# �z��ɒǉ�
					#if($type =~ /Get-index/){
					#		foreach(@{$comment_boad->{'res_data'}}){
					#			push(@index_line,[$account,$key,$rgtime,$account2,$name,$trip,$id,$comment,$dates,$xip,$res,$deleter,$control_handle2,$res_concept2,$text_color2]);
					#		}
					#}

	}

	# �z������n��Ƀ\�[�g
	if($type =~ /Multi-accounts/){
		@index_line = sort { $b->{'regist_time'} <=> $a->{'regist_time'} } @index_line;
	}

my @index_line_adjusted = @{$sns_account->add_handle_to_data_group(\@index_line)};

	# �z���W�J
	if($type =~ /Get-index/){

			# ���z���W�J
			foreach(@index_line_adjusted){

				# ���E���h�J�E���^
				$i_foreach++;
				$i++;

					# �\�������I�[�o�[�����ꍇ
					if($i > $maxview && $type !~ /Multi-account/){ $flow_flag = 1; last; }

						# �}���`�\���p
						if($type =~ /Multi-account/){
								# �I�����ꂽ�A�J�E���g�ŁA�Ȃ����A����̃A�J�E���g�̓`���̂ݑI������ ( �����̓`���ւ́A�����̓`���͑I�΂Ȃ� )
								if($multi_account{$_->{'account'}} && $_->{'main_account'} ne $_->{'account'}){
									1;
								} else {
									next;
								}
						}

					# ���[�h����
					if($param->{'word'} ne "" && ($_->{'account'} !~ /\Q$param->{'word'}\E/ && $_->{'comment'} !~ /\Q$param->{'word'}\E/ && $_->{'name'} !~ /\Q$param->{'word'}\E/) ){ next; }

				# �q�b�g�J�E���^
				$hit++;

					# ������
					if($my_use_device->{'mobile_flag'} && $hit >= 2){ $comments .= qq(<hr>); }

					my $css_class_in = qq( $multi_background_class{$account}) if($type =~ /Multi-accounts/);

					($comments) .= auth_view_comment_core({ multi_flag => $multi_flag , css_class_in => $css_class_in } , $_);

			}
	}



# ���o����`
my $h2 .= qq(<h2 id="COMMENT"$kfontsize_h2>);
	if($type =~ /PROF/ && $flow_flag){ $h2 .= qq(<a href="$comment_boad_url">); }
$h2 .= qq($account{'handle'}�ւ̓`��);
	if($type =~ /PROF/ && $flow_flag){ $h2 .= qq(</a>); }
$h2 .= qq(</h2>);

	# �R�����g�������`
	if($comments){
		if($kflag){
			$comments = qq($h2\n$comments);
		}
		else{
			$comments = qq(
			$h2
			<div>
			$comments
			</div>
			);
		}
	}
	else{ $comments = $h2; }

	# ����
	if($year && $type !~ /PROF/ && $flow_flag){ $comments = qq($comments<a href="./viewcomment-$year-all">����</a>); }


	# �R�����g�ۂ̔���
	if($account{'key'} eq "2"){ $form .= qq(���A�J�E���g�����b�N���̂��ߏ������߂܂���<br>); $stop = 1; }
	elsif($account{'let_flag'}){ $form .= qq(��$account{'let_flag'}); $stop = 1; }
	elsif($account{'friend_status_to'} eq "deny"){ $form .= qq(���֎~�ݒ蒆�̂��߃R�����g�ł��܂���<br$xclose>); $stop = 1; }
	elsif($account{'ocomment'} eq "0"){ $form .= qq(���A�J�E���g�� ( $accounts[0] ) �������R�����g�ł��܂�<br>); if(!$account{'myprof_flag'}){ $stop = 1; } }
	elsif($account{'ocomment'} eq "2"){
		$form .= qq(��$main::friend_tag�������R�����g�ł��܂�<br>);
			if($account{'friend_status_to'} ne "friend" && !$account{'myprof_flag'}){ $stop = 1; }
	}

	# ���O�C���֌W
	if(!$idcheck){ $form = qq(���R�����g����ɂ�<a href="$main::auth_url?backurl=$main::selfurl_enc">���O�C���i�܂��͐V�K�o�^�j</a>���Ă��������B<br>); $stop = 1; }
	elsif($main::birdflag){ $form = qq(���R�����g����ɂ�<a href="$main::auth_url$my_account->{'file'}/#EDIT">���Ȃ��̕M��</a>��ݒ肵�Ă��������B<br$xclose>); $stop = 1; }

# �g�s�l�k�ŏI�o�͒�`
$form .= qq(������J - ���Ȃ��ȊO�ɂ͌����܂��� ) if($account{'ocomment'} eq "3");


	# �҂����ԕ\��
	if(time < $my_account->{'next_comment_time'}){
		my($next_splittime) = Mebius::SplitTime(undef,$my_account->{'next_comment_time'}-$main::time);
		$form .= qq( �����݃`���[�W���Ԓ��ł��B����$next_splittime�ŏ������߂܂��B);
		#$stop = 1;
	}


	# �Ǘ��҂̏ꍇ
	if($my_account->{'admin_flag'}){ $stop = ""; }

	# �R�����g�t�H�[����ʏ�\��
	if($main::stop_mode =~ /SNS/){
		$form .= qq(<div><br$main::xclose><span class="alert">���݁ASNS�S�̂œ��e��~���ł��B</span></div>);
	}
	elsif(!$stop){
		my($select_line) = Mebius::Init::Color("Get-select-tags",$my_account->{'comment_font_color'});

		$form .= qq(<form action="$main::action" method="post" class="pform"$main::sikibetu>\n);

			if($type =~ /UTF-8/){
				$form .= $query->input_hidden_encode();
			}
		$form .= qq(<div>\n);
		$form .= qq(<textarea name="comment" class="ctextarea" cols="25" rows="5"></textarea>\n);
		$form .= qq(<br$xclose>\n); 
		$form .= qq(<input type="submit" value="���̓��e�œ`������"$xclose>\n);
		$form .= qq(<select name="color">\n$select_line</select>\n);
			if($type =~ /Back-url/){ $form .= Mebius::back_url_hidden(); }
		$form .= qq(<input type="hidden" name="mode" value="comment"$xclose>\n);
		$form .= qq(<input type="hidden" name="account" value="$accounts[0]"$xclose>\n);
		#$form .= qq(<strong class="alert">�������ނ� �ڑ��f�[�^ ( $main::addr ) ���T�[�o�[�����ɋL�^����A <a href="${main::adir}aview-allcomment.html" class="blank" target="_blank">�V���`��</a> ���X�V����܂��B �@</strong>\n);
		#$form .= qq(<span class="guide">�i�S�p$main::max_msg_comment�����܂Łj�B</span>\n);
		$form .= qq(</div>\n);
		$form .= qq(</form>\n);

	}

	# ���폜�˗����[�h�̏ꍇ�A�t�H�[����ǉ�
	if(Mebius::Report::report_mode_judge()){
		($comments) = Mebius::Report::around_report_form($comments);

	# ���R�����g����{�^��
	#} elsif($control_flag){
	} elsif($my_account->{'login_flag'}){

		# �Ǐ���
		my($method);
		our($backurl_input);

		# ���\�b�h��`
		#if($alocal_mode){ $method = "get"; }
		#else{ $method = "post"; }
		$method = "post";

		$comments = qq(
		<form action="$main::auth_url" method="$method"$main::sikibetu>
		<div>
		$comments
		<input type="hidden" name="mode" value="comdel"$xclose>
		<input type="hidden" name="account" value="$accounts[0]"$xclose>
		<input type="hidden" name="year" value="$main::submode2"$xclose>
		<input type="hidden" name="thismode" value="$main::mode"$xclose>
		$input_years 
		$backurl_input
		<div class="control_submit">
		<input type="submit" value="�R�����g��������s����"$xclose>
		</div>
		</div>
		</form>
		);
	} 


	# �����̃R�����g�������擾
	if($type !~ /Low-load/){
		#my(%comment_history) = Mebius::Auth::CommentBoadHistory("Get-oneline",$my_account->{'file'});
		#	if($comment_history{'oneline_line'}){
		#		$form .= qq(<div class="right word-spacing">���Ȃ��̓`�������F );
		#		$form.= qq($comment_history{'oneline_line'});
		#		$form .= qq(<a href="${main::auth_url}$my_account->{'file'}/aview-history#COMMENT_HISTORY">�c�����ƌ���</a>);
		#		$form .= qq(</div>\n);
		#	}
	}

	# ���`
	if($type =~ /PROF/){
		$comments = 
		qq($comments) .
		qq(<div class="comment-next">).
		qq(<a href="$comment_boad_url">�����b�Z�[�W�̑���������</a>) .
		qq(</div>);
	}

	# �t�H�[��������
	if($type =~ /Multi-accounts/){
		$form = "";
	}

return($comments,$form);

}


#-----------------------------------------------------------
# �\�����e ( �R�A���� )
#-----------------------------------------------------------
sub auth_view_comment_core{

my($use,$data) = @_;
my $fillter = new Mebius::Fillter;
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
my($my_use_device) = Mebius::my_use_device();
my($account,$key,$rgtime,$account2,$trip,$id,$comment,$dates,$xip,$res,$deleter,$control_handle2,$res_concept2,$text_color2) = 
($data->{'main_account'},$data->{'key'},$data->{'regist_time'},$data->{'account'},$data->{'trip'},$data->{'id'},$data->{'comment'},$data->{'dates'},$data->{'xip'},$data->{'res_number'},$data->{'deleter'},$data->{'control_account'},$data->{'concept'},$data->{'text_color'});
my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);
my($viewdate) = sprintf("%04d/%02d/%02d %02d:%02d", $year,$month,$day,$hour,$min);
my($control_box,$comments,$viewres,$trclass_in,$class,$handle_style,$report_check_box,$control_flag,$name);
our($del,$xclose);

	if( my $target = $data->{'handle'}){
		$name = shift_jis_return($target);
	} else {
		$name = $data->{'name'};
	}

my $link = qq($basic_init->{'auth_url'}$account2/);

	$comment =~ s/<br>/ /g;

	if( my $message = $fillter->each_comment_fillter_on_shift_jis($comment)){
		$comment = $message;
	}

($comment) = Mebius::auto_link($comment);

	# �����F
	if($text_color2){
		$comment = qq(<span style="color:$text_color2;">$comment</span>);
		$handle_style = qq( style="color:$text_color2;");
	}

	if($res && $res !~ /\D/){ $viewres = qq(No.$res); }

	# ���ᔽ�񍐃{�b�N�X
	if(Mebius::Report::report_mode_judge() && $res ne ""){
		my $comment_deleted_flag = 1 if($key ne "1");
		my $year_select_name = "_${year}";
		($report_check_box) = shift_jis(Mebius::Report::report_check_box_per_res({ comment_deleted_flag => $comment_deleted_flag },"sns_comment_boad_${account}_${res}$year_select_name"));
		# handle => $handle_utf8 , handle_deleted_flag => $res_concept{'Deleted-handle'} 
		#$res_number
	# ���R�����g����{�b�N�X���`
	} elsif($my_account->{'login_flag'} && ($my_account->{'admin_flag'} || $main::submode1 eq "viewcomment")){

		my $input_name;

			if($res ne ""){
				$input_name = qq(sns-comment-delete-by-res_number-$account-$res);
			} else {
				$input_name = qq(sns-comment-delete-by-regist_time-$account-$rgtime);
			}
			if($year){
				$input_name .= qq(-).e($year);
			}

			# �폜�{�b�N�X ( ��ʗp )
			if($key eq "1" && ($account eq $my_account->{'file'} || $account2 eq $my_account->{'file'}) && !$my_account->{'admin_flag'}){ # $accounts[0] eq
				$control_box .= qq( <input type="checkbox" name=").e($input_name).qq(" value="delete"$xclose>�폜);
			}


			# ���폜�{�b�N�X ( �Ǘ��p )
			if($my_account->{'admin_flag'} || Mebius::Admin::admin_mode_judge()){

					# ����{�b�N�X�̐��`�i�Ǘ��p�j
					if($control_box){
						$control_box = qq( <label><input type="radio" name=").e($input_name).qq(" value="").e($main::parts{'checked'}).qq(><span>���I��</span></label>$control_box);
					}

				$control_box .= qq( <label><input type="radio" name=").e($input_name).qq(" value="no-reaction"><span>�Ή����Ȃ�</span></label>);

					if($key eq "1"){
						$control_box .= qq( <label><input type="radio" name=").e($input_name).qq(" value="penalty"><span class="red">���폜</span>);
					}

					# �폜�{�b�N�X ( �Ǘ��p )
					if($key eq "1"){
						$control_box .= qq( <label><input type="radio" name=").e($input_name).qq(" value="delete"><span>�폜</span></label>);
					}

					# �����{�b�N�X
					if($key ne "1"){
						$control_box .= qq( <label><input type="radio" name=").e($input_name).qq(" value="revive"><span class="blue">����</span></label>);
					}

			}

			# ����{�b�N�X�̐��`�i���ʁj
			if($control_box){
				$control_flag = 1;
				$control_box = qq(<br$main::xclose><div class="control">$control_box</div>);
			}

	}

	# �폜�ς݂̏ꍇ
	if($key ne "1"){
		my($deleted_text);
			if($key eq "2"){ $deleted_text = qq(�y�A�J�E���g��폜�z); }
			elsif($key eq "3"){ $deleted_text = qq(�y���e��폜�z); }
			elsif($key eq "4"){ $deleted_text = qq(�y�Ǘ��ҍ폜�z $deleter); }
		
			if($my_account->{'admin_flag'}){ $comment = qq(<span class="deleted">$comment $deleted_text $res_concept2</span>); }
			else{ $comment = qq(<span class="deleted">$deleted_text</span>); }

		$name = "";

	}

	# �s�̕\���X�^�C�����`
	if($key ne "1" && $my_account->{'admin_flag'}){ $trclass_in = qq( deleted); }
	elsif($use->{'css_class_in'}){ $trclass_in = $use->{'css_class_in'}; }

#	elsif($type =~ /Multi-accounts/){ $trclass_in = qq( $multi_background_class{$account}); }
#	elsif($i_foreach % 2 == 0){ $trclass_in = qq( shadow); }

	# �\���s���`�i�g�сj
	if($my_use_device->{'mobile_flag'}){
		$comments .= qq(<div id="C$res"><a href="$link"$class>$name - $account2</a>);
		$comments .= qq( ( <a href="$link#COMMENT">�ԐM</a> )<br$main::xclose>$comment $del);
		$comments .= qq( $viewdate - $viewres$control_box);
		$comments .= $report_check_box;
		$comments .= qq(</div>);
	}

	# �\���s���`�i�o�b�j
	else{
		$comments .= qq(<div class="dcm $trclass_in" id="C$res">);
		$comments .= qq(<a href=").e($link).qq("$class$handle_style>$name \@$account2</a>);
		$comments .= qq( &gt; $comment $del);

			#if($account2 ne $account){
			if($use->{'multi_flag'}){
				$comments .= qq( ( <a href="$basic_init->{'auth_url'}${account}/viewcomment#C$res">����</a> ));
			}
			else{
				$comments .= qq( ( <a href="${link}viewcomment#COMMENT-INPUT">�ԐM</a> ));
			}
			#}
			if($my_account->{'file'} && $account ne $account2 && !$use->{'multi_flag'} && $my_account->{'file'}){
				$comments .= qq( ( <a href="/viewcomment-multi-$account,$account2.html">����</a> ) ); 
			}

		$comments .= qq(<div class="right">$viewdate - $viewres$control_box</div>);
			if($my_account->{'master_flag'}){
				$comments .= qq(<div class="right">$xip</div>);
			}
		$comments .= $report_check_box;
		$comments .= qq(</div>\n);
	}

$comments;

}

package Mebius::Auth;

#-----------------------------------------------------------
# �`���ւ̃R�����g����
#-----------------------------------------------------------
sub CommentBoadHistory{

# �錾
my($type,$account) = @_;
my(undef,undef,$new_account,$new_res_number,$new_handle) = @_ if($type =~ /New-comment/);
my($file_handler,$i,%comment_history,@renew_line,$oneline_line,$index_line,@new_res_number);

# �A�J�E���g������
if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �t�@�C����`
my $directory1 = "${account_directory}comments/";
my $file = "${directory1}commentboad_history.log";

# �t�@�C�����J��
open($file_handler,"<$file");

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($file_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$file_handler>);
($comment_history{'concept'}) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$file_handler>){

		# �Ǐ���
		my($res_number_counts2,@res_number2);

		# ���E���h�J�E���^
		$i++;
		
		# ���̍s�𕪉�
		chomp;
		my($key2,$account2,$res_number2,$handle2,$lasttime2,$date2) = split(/<>/);

			# �ϐ�����
			foreach(split(/\s/,$res_number2)){
				push(@res_number2,$_);
				$res_number_counts2++;
			}
			my $first_res_number2 = $res_number2[0];

			# �V�K�o�^�̏ꍇ
			if($type =~ /New-comment/){
					# �d���̓G�X�P�[�v
					if($account2 eq $new_account){
						@new_res_number = @res_number2;
						next;
					}
			}

			# �X�V�s��ǉ�
			if($type =~ /Renew/){

					# �ő�s���ɒB�����ꍇ
					if($i >= 100){ last; }

				push(@renew_line,"$key2<>$account2<>@res_number2<>$handle2<>$lasttime2<>$date2<>\n");
			}


			# �C���f�b�N�X�擾�p
			if($type =~ /Get-index/){

					# �ő�s���ɒB�����ꍇ
					if($i >= 30){ last; }

				$index_line .= qq(<tr>\n);
				$index_line .= qq(<td>);
				$index_line .= qq(<a href="${main::auth_url}$account2/">$handle2 - $account2</a>);
				$index_line .= qq(</td>);
				$index_line .= qq(<td>);
				$index_line .= qq(( <a href="${main::auth_url}$account2/viewcomment">�`����</a> ));
				$index_line .= qq(</td>);
				$index_line .= qq(<td>);
				$index_line .= qq(<a href="${main::auth_url}$account2/viewcomment#C$first_res_number2">&gt;&gt;$first_res_number2</a>);
				$index_line .= qq(</td>);
				$index_line .= qq(<td>);
				$index_line .= qq($res_number_counts2);
				$index_line .= qq(</td>);
				$index_line .= qq(<td>);
				$index_line .= qq($date2);
				$index_line .= qq(</td>);

				$index_line .= qq(</tr>\n);

			}

			# �g�s�b�N�X�擾�p
			if($type =~ /Get-oneline/ && $i <= 5){
				$oneline_line .= qq(<a href="${main::auth_url}$account2/#COMMENT">$handle2</a>\n);
			}

	}

close($file_handler);

	# �C���f�b�N�X���`
	if($type =~ /Get-index/){

		
	}

	# �V�����R�����g�����ꍇ
	if($type =~ /New-comment/){
		unshift(@new_res_number,$new_res_number);
		unshift(@renew_line,"<>$new_account<>@new_res_number<>$new_handle<>$main::time<>$main::date<>\n");
	}

	# �t�@�C���X�V
	if($type =~ /Renew/){

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$comment_history{'concept'}<>\n");

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file,@renew_line);
	}
	

# �n�b�V������
$comment_history{'oneline_line'} = $oneline_line;

	# �C���f�b�N�X���`
	if($type =~ /Get-index/){
		$comment_history{'index_line'} .= qq(<table>);
		$comment_history{'index_line'} .= qq(<tr>);
		$comment_history{'index_line'} .= qq(<th>�A�J�E���g</th><th>�`����</th><th>���X��</th><th>���e��</th><th>���t</th>);
		$comment_history{'index_line'} .= qq(</tr>);
		$comment_history{'index_line'} .= qq($index_line);
		$comment_history{'index_line'} .= qq(</table>);

	}




return(%comment_history);

}

package main;

#-----------------------------------------------------------
# �R�����g���s
#-----------------------------------------------------------
sub auth_comment{

my $all_comments = new Mebius::AllComments
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my($file,$line,$i,$timeline,$pastline,$indexline,$waittop1,$add_pastline,$i,$newresnumer);
my($init_directory) = Mebius::BaseInitDirectory();
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;
my $time = time;
my $param_sjis = Mebius::Query->single_param_shift_jis();
my $query = new Mebius::Query;
my $param  = $query->param();our($thisyear,$thismonth,$today,$thishour,$thismin,$thissec,$date,$xip);
my %in = our %in;

# �ő働�O���i���s�j
my $maxcomment = 1000;

# �P�R�����g�̑҂��b��
my $next_wait_comment = 30;

# �G���[���̃t�b�N���e
$main::fook_error = qq(���͓��e�F $in{'comment'});

# �����`�F�b�N
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

my $comment_utf8 = utf8_return($param->{'comment'});
	if($all_comments->dupulication_error($comment_utf8)){
		main::error("���d�����e�ł��B");
	}

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ���O�C�����̂݃R�����g�\
	if(!$my_account->{'login_flag'}){ &error("�R�����g����ɂ̓��O�C�����Ă��������B"); }

# �A�N�Z�X����
main::axscheck("ACCOUNT Post-only");

	# �`���[�W���ԃ`�F�b�N
	if(time < $my_account->{'next_comment_time'} && !$my_account->{'admin_flag'} && !Mebius::alocal_judge()){
		my($left_charge) = Mebius::SplitTime(undef,$my_account->{'next_comment_time'} - time);
		main::error("�`���[�W���Ԓ��ł��B���� $left_charge ���҂����������B");
	}

# ����̃v���t�B�[�����J��
my(%account) = Mebius::Auth::File("Hash File-check-error Key-check-error Lock-check-error Option",$file);

# �e��`�F�b�N
require "${init_directory}regist_allcheck.pl";
Mebius::Regist::name_check($my_account->{'name'});
($in{'comment'}) = &all_check(undef,$in{'comment'});
my($new_text_color) = Mebius::Regist::color_check(undef,$main::in{'color'});
&error_view("View-break-button AERROR");

# �������`�F�b�N
if(length($in{'comment'}) > $main::max_msg_comment*2){
my $length = int(length($in{'comment'}) / 2);
&error("�R�����g���������܂��B�S�p$main::max_msg_comment�����Ɏ��߂Ă��������B�i����$length�����j");
}

# �{�����Ȃ��ꍇ
if (($in{'comment'} eq "")||($in{'comment'} =~ /^(\x81\x40|\s|<br>)+$/)) { &error("�R�����g���e������܂���B"); }
if($in{'comment'} =~ /(����|�莆)/){ &error("�u���ʁv�u�莆�v�̃L�[���[�h�͎g���܂���B���ʑ����W�ȂǁA�l���̌����͐�΂ɂ��Ȃ��ł��������B�{�T�C�g�̗��p���i���ɂ��f�肳���Ă��������ꍇ������܂��B"); }

# ���݂��̋֎~��Ԃ��`�F�b�N
my($friend_status1) = Mebius::Auth::FriendStatus("Deny-check-error",$account{'file'},$my_account->{'file'});
my($friend_status2) = Mebius::Auth::FriendStatus("Deny-check-error",$my_account->{'file'},$account{'file'});

	# �A�J�E���g�x�����̏ꍇ
	if($account{'let_flag'} && !$my_account->{'admin_flag'}){ main::error("$account{'let_flag'}"); }

	# �R�����g�ۂ𔻒�
	if(!$account{'myprof_flag'} && !$my_account->{'admin_flag'}){
			if($account{'ocomment'} eq "0"){ &error("�A�J�E���g��ȊO�̓R�����g�ł��܂���B"); }
			elsif($account{'ocomment'} eq "2" && $friend_status1 ne "friend"){ &error("$main::friend_tag�ȊO�̓R�����g�ł��܂���B"); }
			elsif($account{'ocomment'} eq "3"){ &error("�`���ł͔���J�ɂȂ��Ă��܂��B"); }
	}
	if($main::birdflag){ &error("�R�����g����ɂ͂��Ȃ��̕M����ݒ肵�Ă��������B"); }


# ���b�N�J�n
&lock("auth${file}");

my $pfcdate = "$thisyear,$thismonth,$today,$thishour,$thismin,$thissec";

# �R�����g�t�@�C���ǂݍ���
open(COMMENT_IN,"<","${account_directory}comments/${file}_comment.cgi");
chomp(my $top_comment = <COMMENT_IN>);
my($res,$lasttime) = split(/<>/,$top_comment);
$res++;
$line .= qq($res<>\n);
my $newresnumber = $res;
$line .= qq(1<>$time<>$my_account->{'id'}<>$my_account->{'name'}<>$my_account->{'enctrip'}<>$my_account->{'encid'}<>$in{'comment'}<>$pfcdate<>$xip<>$res<><><><>$new_text_color<>\n);

# �V�X�e���ύX���̒����i�P�s���j
if($lasttime){ $line .= qq($top_comment\n); }
	while(<COMMENT_IN>){
		if($i < $maxcomment-1){ $line .= $_; }
		$i++;
	}
close(COMMENT_IN);

# �R�����g�t�@�C�������o��
Mebius::Fileout(undef,"${account_directory}comments/${file}_comment.cgi",$line);

# �ߋ����O�A�R�����g�t�@�C����ǂݍ���
open(COMMENT_PAST_IN,"<","${account_directory}comments/${file}_${thisyear}_comment.cgi");
	while(<COMMENT_PAST_IN>){
		$pastline .= $_;
	}
close(COMMENT_PAST_IN);

	# �����̉ߋ����O���Ȃ���΁A�R�����g�̃C���f�b�N�X�ɍs��ǉ�
	if($pastline eq ""){

		# �C���f�b�N�X�ɒǉ�����s
		$indexline .= qq(${thisyear}<>\n);

		# �R�����g�C���f�b�N�X��ǂݍ���
		open(INDEX_PAST_IN,"<","${account_directory}comments/${file}_index_comment.cgi");
		while(<INDEX_PAST_IN>){
			my($year) = split(/<>/,$_);
			if($year ne $thisyear){ $indexline .= $_; }
		}
		close(COMMENT_PAST_IN);

		# �R�����g�C���f�b�N�X�ɏ�������
		Mebius::Fileout(undef,"${account_directory}comments/${file}_index_comment.cgi",$indexline);

	}

# �ߋ����O�ɒǉ�����s
$add_pastline .= qq(1<>$time<>$my_account->{'id'}<>$my_account->{'name'}<>$my_account->{'enctrip'}<>$my_account->{'encid'}<>$in{'comment'}<>$pfcdate<>$xip<>$res<><><><>$new_text_color<>\n);

# �f�B���N�g���쐬
Mebius::mkdir("${account_directory}comments/");

# �ߋ����O�A�R�����g�t�@�C���������o��
my $past_file_line = $add_pastline . $pastline;
Mebius::Fileout(undef,"${account_directory}comments/${file}_${thisyear}_comment.cgi",$past_file_line);

# �V���C���f�b�N�X���J��
my $line_allcomment .= qq(1<>$file<>$account{'name'}<>$my_account->{'id'}<>$my_account->{'name'}<>$in{'comment'}<>$date<>$res<>\n);
my($iallcomment);
open(ALLCOMMENT_IN,"<","${auth_log_directory}newcomment.cgi");
	while(<ALLCOMMENT_IN>){
		$iallcomment++;
			if($iallcomment < 500) { $line_allcomment .= $_; }
	}
close(ALLCOMMENT_IN);

# �V���C���f�b�N�X����������
Mebius::Fileout(undef,"${auth_log_directory}newcomment.cgi",$line_allcomment);

# ���b�N����
&unlock("auth${file}");

# �����̃I�v�V�����t�@�C�����X�V
my(%renew_myoption);
$renew_myoption{'next_comment_time'} = time + 15;
$renew_myoption{'comment_font_color'} = $new_text_color;
#Mebius::Auth::Optionfile("Renew",$my_account->{'file'},%renew_myoption);
Mebius::Auth::File("Renew Option",$my_account->{'file'},\%renew_myoption);



	# ����A�J�E���g�� �u�ŋ߂̍X�V�v�t�@�C�����X�V
	if(!$account{'myprof_flag'} || Mebius::alocal_judge()){
		Mebius::Auth::News("Renew Hidden-from-index Log-type-comment",$file,$my_account->{'id'},$my_account->{'handle'},qq(<a href="$main::auth_url$file/viewcomment#C$newresnumber">�`����</a>�ւ̃��X\(No.$newresnumber\)));
	}

# �����X�����X�V
Mebius::Newlist::Daily("Renew Comment-auth");

# ����A�J�E���g�Ƀ��[���𑗐M
my %mail;
$mail{'url'} = "$account{'file'}/viewcomment#COMMENT";
$mail{'comment'} = $main::in{'comment'};
$mail{'subject'} = qq($my_account->{'name'}���񂪓`���ɏ������݂܂����B);
Mebius::Auth::SendEmail(" Type-comment",\%account,\%main::myaccount,\%mail);

# �`���ւ̃R�����g�������X�V
Mebius::Auth::CommentBoadHistory("New-comment Renew",$my_account->{'file'},$file,$res,$account{'name'});

# �����̊�{���e�����t�@�C�����X�V
Mebius::HistoryAll("Renew My-file");

$all_comments->submit_new_comment($comment_utf8);

# �W�����v��$jump_sec = $auth_jump;
my $jump_url = "$main::auth_url${file}/#COMMENT";

# �N�b�L�[���Z�b�g
#Mebius::Cookie::set_main({ font_color => $new_text_color },{ SaveToFile => 1 });

# ���_�C���N�g
	if($param->{'backurl'}){
		Mebius::Redirect("",$param->{'backurl'}."#COMMENT");
	} else {
		Mebius::Redirect("",$jump_url);
	}
# �����I��
exit;

}

1;
