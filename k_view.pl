
use Mebius::Paint;
use Mebius::BBS;
use Mebius::Text;
package main;

#-----------------------------------------------------------
# �g�єł̋L���{��
#-----------------------------------------------------------
sub bbs_view_thread_mobile{

# �Ǐ���
local($no,$sub,$res,$key,$no2,$nam,$trip,$com,$dat,$ho,$id,$color,$pno);
local($job) = @_;
my($type) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # �����^�C�v��W�J
my($zero_line,$use_thread,$main_thread,$sub_thread);

# �g�ѐݒ���擾
&kget_items();

# �ݒ�
$k_maxlink = 2;


# �g�уt���O
$kflag = 1;

# �����ˁI�����擾
#&thread_viewsupport_mobile();

# �����`�F�b�N
if($in{'no'} =~ /\D/){ &error("�L���i���o�[�̎w�肪�ςł��B�����݂̂��w�肵�Ă��������B"); }
$in{'no'} =~ s/\D//g;

# �}�C�y�[�W�̖߂��
$mybackurl = "http://$server_domain/_$moto/$in{'no'}.html";

	# �L���f�[�^��ǂݍ��� �i�T�u�L���j
	if($subtopic_mode){
		require "${int_dir}part_subview.pl";
		($main_thread,$sub_thread) = thread_sub_base();
		$use_thread = $sub_thread;

	# �L���f�[�^��ǂݍ��� (���ʋL���j
	} else {
		($main_thread) = Mebius::BBS::thread_state($in{'no'},$realmoto);
		$use_thread = $main_thread;
		chomp($top1 = $use_thread->{'all_line'}->[0]);
		chomp($top2 = $use_thread->{'all_line'}->[1]);
		($no,$sub,$res,$key,$res_pwd,$t_res,$d_delman,$d_password,$dd1,$sexvio,$dd3,$dd4,$dd5,$memo_body,$dd7,$lock_end_time,$juufuku_com,$dd10) = split(/<>/, $top1);
		#close(IN);
	}

	# �����ˁI�����擾
	if(!Mebius::BBS::sub_bbs_judge_auto()){
		my($count) = Mebius::BBS::get_crap_count($_[0],$use_thread);
		our $pri_count = "($count)";
	}


# �X���b�h�L�[
our $thread_key = $no;

# �T�u�L���f�[�^��ǂݍ���
if($subtopic_link){ ($subkey,$subres,$sub_nofollow) = &thread_get_subdata_mobile(); }

# ���X�Ԃ�F��
($No_start,$No_end) = thread_check_resnumber($res);

# �^�C�g����`
&thread_set_title_mobile();

	# ���\���A�\�͕\��������ꍇ
	if($sexvio){ require "${int_dir}part_sexvio.pl"; &sexvio_check($sexvio); }

# ���e�ɂ���čL������
require "${int_dir}part_adscheck.pl";
my($none,$none,$none,$none,$zero_com) = split(/<>/,$top2);
&adscheck($sub,$zero_com);
	Mebius::Fillter::fillter_and_error(utf8_return($sub));
if($key eq "7"){ $noads_mode = 1; require "${int_dir}part_thread_status.pl"; &thread_get_deletelock("LIGHT MOBILE",{ delete_data => $d_delman }); }
if($sub eq ""){ $noads_mode = 1; $sub = "�����y�[�W"; }

# �\��폜����Ă���ꍇ�A�������߂���ƍ폜�ς݂�
if( ($key eq "7" && $time >= $dd4) || $key eq "6"){ $key = 4; }

# �L���������ꍇ�A404��Ԃ�
if($key eq ""){ main::error("�L��$in{'no'}�͑��݂��܂���","404 NotFound"); }

# �L�����G���A���擾
my($sub_line) = &bbs_get_subline_mobile();

# �������[�h�̏���
local($badword_flag);
if($ch{'word'}){
require "${int_dir}part_tsearch.pl";
($badword_flag) = &tsearch_check_keyword($in{'word'});
}

# ���X�擾
my($res_line) = &thread_nres_mobile($use_thread);

# No.0���擾
if(!$subtopic_mode){ ($zero_line) = &thread_get_zero_mobile(); }

# �y�[�W�֕��������N���擾
my($page_links_top) = &thread_get_pagelinks_mobile("Top",$in{'r'},$res,$kpage,$kfirst_page);
my($page_links_bottom) = &thread_get_pagelinks_mobile("Bottom",$in{'r'},$res,$kpage,$kfirst_page);

# �Ō�̃��X
if($last_res eq ""){ $last_res = 0; }

# �[���L���ւ̈ړ������N
my $movezero = qq(<a href="#RES" id="TOP2">��</a>);
if(!$ch{'No'} && !$ch{'word'}){ $movezero = qq(<a href="#S0" id="TOP2">��</a>); }
#my $middle_link = qq(<a href="#RESFORM" accesskey="5">�D�ԐM</a>);

# �w�b�_

# �폜�˗����[�h�̏ꍇ�A�t�H�[����ǉ�
($res_line) = Mebius::Report::around_report_form($res_line,"bbs_thread_$use_thread->{'bbs_kind'}_$use_thread->{'number'}");


# �񍐃{�^��
my($move_to_report_mode_button) = Mebius::Report::move_to_report_mode_button({ url_hash => "#a" , ViewResReportButton => our $res }); # $use_thread->{'res'}
shift_jis($move_to_report_mode_button);

# HTML
my $print = qq(
$sub_line
$delete_link
$pv_view
$resnavi_links1
$zero_line
$cutlink
$page_links_top

$res_line

$resnavi_links2
$page_links_bottom
<hr>
$move_to_report_mode_button
);



# ���e�t�H�[��
	if(!Mebius::Report::report_mode_judge()){
		$print .= kform2();
	}

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

#-----------------------------------------------------------
# �L�����G���A���擾
#-----------------------------------------------------------
sub bbs_get_subline_mobile{

# �Ǐ���
my($line,$datalinks,$form);
my($my_access) = Mebius::my_access();
my($pageview);
our($concept);

# �J�e�S���ݒ����荞��
my($init_bbs) = Mebius::BBS::init_bbs_parmanent($moto);

# �폜�ς݂̏ꍇ
if($key eq "4") { require "${int_dir}part_thread_status.pl"; &thread_get_deletelock("HEAVY MOBILE",{ delete_data => $d_delman }); }

# �y�[�W�r���[�̌Ăяo���A�J�E���g
	if(!Mebius::Switch::light() && !Mebius::Switch::thread_light()){
		require "${int_dir}part_pv.pl";
		my($pageview) = &do_pv({ TypeRenew => 1 ,TypeAddRanking => 1 },$in{'no'},$moto);
	}

# �s���~�ߋL��
if($key eq "2") { $line .= qq(�s���~�ߋL��<hr$xclose>\n); }

# �e�L����\�� �g��

	# �m����؂肠��ꍇ�A�L���������̋L���փ����N
	if($in{'No'} ne "" || $in{'r'} ne "" || $in{'word'} ne ""){
		$sub = qq(<a href="$in{'no'}.html" style="font-size:medium;">$sub</a>);
	}
	else{
		$sub = qq(<span style="font-size:medium;">$sub</span>);
	}


# �L���^�C�g��
$form = qq(
<form action="$script#FORM" id="FORM" style="text-align:center;margin:0.5em 0em;">
<div style="font-size:x-small;">
<input type="hidden" name="mode" value="kview"$xclose>
<input type="hidden" name="no" value="$in{'no'}"$xclose>
<input type="text" name="word" value="$in{'word'}" size="10"$xclose>
<input type="submit" value="����"$xclose>
</div>
</form>
);



	if($in{'No'} eq "" && $concept !~ /NOT-SUPPORT/){
			if($my_access->{'level'} >= 2 && 1 == 0) {
				$datalinks .= qq( <a href="./?mode=support&amp;no=$in{'no'}&amp;k=1"$sikibetu>�����ˁI$pri_count</a>);
			} else { 
				$datalinks .= " �����ˁI$pri_count";
			}
	}

	if($my_access->{'level'} >= 2) {
		$datalinks .= qq( <a href="./?mode=cermail&amp;no=$in{'no'}">�z�M</a>);
	}

	if($key ne "0"){ $datalinks .= qq( <a href="$in{'no'}_data.html">�f�[�^</a>);  }

	# �폜�˗������N
	my($delete_link);
	if($secret_mode){ $datalinks .= qq( <a href="scmail.html">�Ǘ���</a>); }
	#else{
	#	my $bbs_url = new Mebius::BBS::URL;
	#	$datalinks .= qq( <a href=").e($bbs_url->report_thread($init_bbs)).qq(" target="_blank" class="blank">�폜�˗�</a>);
	#}

	my($pc_link,$s0);
		if($device_type eq "both"){
			$datalinks .= qq( <a href="$in{'no'}.html">PC��</a>);
		}

# �o�u
if(defined($pageview)){ $datalinks .= qq( ����${pageview}); }

$line .= qq();

my($support_comment_form) = &thread_support_comment_form() if($mode eq "support");

# �L���������I���
$line .= qq(
$sexvio_text
<div style="background:#dee;border-bottom:solid 1px #000;">

$sub

<span style="font-size:x-small;">$datalinks</span>
</div>
$support_comment_form
$form
);


return($line);

}

#-----------------------------------------------------------
# �[���L�����擾
#-----------------------------------------------------------
sub thread_get_zero_mobile{

# �Ǐ���
my($line,$moves);
local($no,$ranum,$nam,$trip,$com,$dat,$ho,$id,$color,$agent,$user,$deleted,$account,$image_data,$res_concept,$regist_time2) = split(/<>/,$top2);
local($round,$mround,$last_flag,$tsearch_hit,$rescut_flag);

	# �A�J�E���g��\���̏ꍇ
	if($res_concept =~ /Hide-account/){ $account = undef; }

	my($comment_deleted_flag) = Mebius::BBS::comment_deleted_judge($res_concept,$deleted);

	# �M�����폜����Ă���ꍇ
	if($res_concept =~ /Deleted-handle/ || $comment_deleted_flag){ $nam = qq(�폜�ς�); $trip = undef; }

# ���^�[��
if($ch{'No'} || $ch{'word'}){ return; }


$line .= qq($ktext_up);

# �t�H�[�}�b�g
($line) .= &thread_getres_mobile("ZERO",$use_thread);

# �T�u�L���̏ꍇ
if($subtopic_mode){ ($line) = &thread_get_ksubzero(); }

	# ���g�ь��� Adsense
	if(!Mebius::Report::report_mode_judge()){

		my($kadsense,$kadsense2) = &kadsense("VIEW");

			if($kadsense){
				$line .= qq(<hr$xclose>$kadsense);
			}

			if($kadsense2){
				$main::kfooter_ads = qq($kadsense2);
			}
	}

# �L���������擾
if(!$subtopic_mode){ ($line) .= &thread_get_memo_mobile(); }


return($line);

}


#-----------------------------------------------------------
# ���X�����o��
#-----------------------------------------------------------
sub thread_nres_mobile{

# �Ǐ���
my($use_thread) = @_;
local($round,$mround,$last_flag,$tsearch_hit,$rescut_flag);
my($line,$reads_hit_flag,$file);
my @thread_data = @{$use_thread->{'all_line'}};

	# �ȗ����̐ݒ�
	#if($ccut ne "0" && $ccut){
	#	$k_maxgyou *= $ccut;
	#	$kmax_length *= $ccut;
	#}


# ���X�J�n / �I���ʒu���`
$res_start = $res - $kfirst_page + 1;
$res_end = $res;
	if($in{'No'} ne ""){ ($res_start,$res_end) = ($No_start,$No_end); }
	elsif($in{'r'} ne ""){
		$res_start = $in{'r'};
		$res_end = $in{'r'} + $kpage - 1;
			if($in{'r'} >= $res - $kfirst_page - $kpage){ $res_end = $res - (($kfirst_page + 1 - 1)  % $kpage) + 1 - 1; }
	}
	elsif($in{'word'} ne ""){
		($res_start) = "";
	}

# ���X���ȗ����邩���Ȃ���
if($ch{'No'}){ $rescut_flag = 0; }

# ���X�J�n�O�̕���
$line .= qq($deleted_text);
$line .= qq(<a id="RES"></a>);

	# �����ꂪ�����ꍇ
	if($badword_flag){ $line .= qq(�����ł��܂���ł����B�S�p�P�����ȏ�̃L�[���[�h���g���Ă��������B); return($line); }

# ���X�Ԏw��̏ꍇ�A�e�탊���N���擾
($line) .= &resnumber_link("1",$No_start,$No_end);

	# ���X��W�J
	if($res_flag ne "0"){

		shift @thread_data ;
			if(!$ch{'No'} && !$ch{'word'}){ shift @thread_data; }

			foreach(@thread_data) { 

				# ���̍s�𕪉�
				chomp;
				local($no,$ranum,$nam,$trip,$com,$dat,$ho,$id,$color,$agent,$user,$deleted,$account,$image_data,$res_concept,$regist_time2) = split(/<>/);

				# �A�J�E���g��\���̏ꍇ
				if($res_concept =~ /Hide-account/){ $account = undef; }

				my($comment_deleted_flag) = Mebius::BBS::comment_deleted_judge($res_concept,$deleted);

				# �M�����폜����Ă���ꍇ
				if($res_concept =~ /Deleted-handle/ || $comment_deleted_flag){ $nam = qq(�폜�ς�); $trip = undef; }

				my($name_hit,$id_hit);

				# ���̏����֐i��
				if($no < $res_start && ($no != 0 || $ch{'No'})){ next; }
				if($no >= $res_end){ $last_flag = 1; }
				if($res_comma){
					my($flag);
						foreach (split(/,/, $in{'No'})) { if($no eq $_) { $flag = 1; } }
						if(!$flag){ next; }
				}
				if($ch{'word'}){
					my($hit);
					my($search) = &bbs_tsearch($in{'word'},"mobile/high-light","$nam��$trip",$com,$id,$account);
					($hit,$name_hit,$id_hit) = ($search->{'hit'},$search->{'$name_hit'},$search->{'id_hit'});
						if($search->{'high_lighted_comment'}){ $com = $search->{'high_lighted_comment'}; }
					$tsearch_hit += $hit;
						if($tsearch_hit >= 30){ $res_end = $no; $last_flag = 1; }
						if(!$hit){ next; }
				}

				# ���S�폜����Ă���ꍇ
				if($res_concept =~ /Vanished/){	}
				# ���ʂɏ����o���ꍇ
				else{
					($line) .= &thread_getres_mobile("",$use_thread);
				}

				$reshit_flag = 1;
				if($deleted eq ""){ $adshit_flag = 1; }

				if($last_flag){ $last_res = $no; last; }


			}

	}

# ���X�Ԏw��̏ꍇ�A�e�탊���N���擾
($line) .= &resnumber_link("2",$No_start,$No_end);

# �\�����e���Ȃ��ꍇ
if(!$reshit_flag && ($ch{'No'} || $ch{'r'}) ){ &error("�\\��������e������܂���B","404 NotFound"); }

	# �L����\������ꍇ
	if($adshit_flag && ($ch{'No'} || $ch{'word'}) ){
		my($kadsense,$kadsense2) = &kadsense("VIEW");
			if($kadsense){
				$line .= qq(<hr$xclose>$kadsense);
			}
			if($kadsense2){
				$main::kfooter_ads = qq($kadsense2);
			}
	}

# �����Ńq�b�g���Ȃ������ꍇ
if($in{'word'} ne "" && !$reshit_flag){ $line .= qq(�q�b�g���܂���ł����B�L�[���[�h��ς��Č������Ă��������B); }


return($line);

}

#-----------------------------------------------------------
# ���X�̃t�H�[�}�b�g
#-----------------------------------------------------------
sub thread_getres_mobile{

# �Ǐ���
my($type,$use_thread) = @_;
my($line,$up_mk,$dw_mk,$up_move,$dw_move,$viewname,$view_no,$edit,$aname);
my($admin,$comview,$cut_round,$cut_round_bridge,$length,$cutflag,$cutlength);
my($plustype_kauto_link,$omit_flag,$omitlink,$image_view,$view_id,$account_link,$view_trip,$report_check_box);
my($basic_init) = Mebius::basic_init();	
my $fillter = new Mebius::Fillter;
our($resone,%ch,$cfillter_id,$cfillter_account);

	# �ȈՃt�B���^
	if($cfillter_id || $cfillter_account){
		use Mebius::BBS;
		my($filled_flag_id) = Mebius::BBS::Fillter_id("",$cfillter_id,$id);
		my($filled_flag_account) = Mebius::BBS::Fillter_account("",$cfillter_account,$account);
		if($filled_flag_id || $filled_flag_account){ next; }
	}


# ���������N�̃^�C�v��`
if($ch{'No'}){ $plustype_kauto_link .= qq( Resone); }
if($main::bbs{'concept'} =~ /Sousaku-mode/){ $plustype_kauto_link .= qq( Loose); }
if($rescut_flag eq "0" || $main::ccut eq "0"){ $plustype_kauto_link .= qq(); }
else{ $plustype_kauto_link .= qq( Omit); }

# ���������N
($com,$omit_flag,$omitlink) = &kauto_link("Thread $plustype_kauto_link",$com,$main::in{'no'},$no);

# ���� �ړ������N���`
$round++;
$up_move = $no + 1;
$dw_move = $no - 1;
$aname .= qq(<a id="S$no"></a><a id="D$no"></a>);
if($type =~ /ZERO/){ $aname = ""; }

	# �㉺�ړ������N�i���ʁj
	if($in{'No'} eq "" && !$ch{'word'} && $type !~ /ZERO/){
		$mround++;
		$aname = "";
			if($last_flag) { $dw_mk = qq(<a href="#DBMENU" id="S$no">��</a>); }
			else { $dw_mk = qq(<a href="#S$up_move" id="S$no">��</a>); }
			if($mround == 1){ $up_mk = qq(<a href="#D0" id="D$no">��</a>); }
			else { $up_mk = qq(<a href="#D$dw_move" id="D$no">��</a>); }
	}

	# �[���ԋL���̈ړ������N
	if($type =~ /ZERO/){
		my $moves = $in{'r'};
			if($moves eq ""){ $moves = $res - $kfirst_page + 1; }
			if($res <= $kfirst_page){ $moves = 1; } 
			if($res >= $moves){
				$dw_mk = qq(<a href="#S$moves" id="S0">��</a>);
				$up_mk = qq(<a href="#TOP2" id="D0">��</a>);
			}
			else{
				$dw_mk = qq(<a href="#DBMENU" id="S0">��</a>);
				$up_mk = qq(<a href="#TOP2" id="D0">��</a>);
			}
	}


	if($res_one && $no == $res_start){ $resone_cutflag = $cutflag; }
	if($res_one){ $cutflag = 0; }

	# �\������
	if($id){ $view_id = "��$id"; }
	if($id_hit){ $view_id = qq(<span style="background:#fc0;">$view_id</span>); }
	elsif($agent eq "<A>"){ $view_id = qq(<span style="color:#f00;">$view_id</span>); }

	# ID���������N
	if($id && $res_concept =~ /Idory5/ && $res_concept !~ /Deleted-(comment|handle)/){
		my($devce_encid,$pure_encid,$option_encid) = Mebius::SplitEncid(undef,$id);
		my($id_encoded) = Mebius::Encode("Escape-slash",$pure_encid);
		$view_id = qq(<a href="${main::main_url}history-id-$id_encoded.html">$view_id</a>\n);
	}

	# �폜�����N
	if($candel_mode && $user eq $username && $deleted eq ""){
		$edit = qq( <a href="$script?mode=resdelete&amp;no=$in{'no'}&amp;type=delete&amp;res=$no&amp;k=1" style="font-size:small;">�폜</a> );
	}

	# �M�������N
	#if($trip){ $viewname = "$nam��$trip"; }
	#else{ $viewname = "$nam"; }

	{ $viewname = "$nam"; }

	# �g���b�v���������N
	if($trip && $res_concept =~ /Tripory/ && $res_concept !~ /Deleted-(comment|handle)/){
		my($trip_encoded) = Mebius::Encode("Escape-slash",$trip);
		my($trip_style) = qq( style="background:#fc0;") if($name_hit);
		$view_trip = qq( <a href="${main::main_url}history-trip-$trip_encoded.html"$trip_style>��$trip</a>\n);
	}
	# ���O���q�b�g�����ꍇ
	elsif($name_hit){ $viewname = qq(<span style="background:#fc0;">$viewname</span>); }

	# �A�J�E���g�����N
	if($account){

		$viewname = qq( <a href=") . esc("${auth_url}$account/") . qq(">$viewname</a> );

			if(Mebius::BBS::view_account_history_judge($res_concept)){
				$account_link .= qq( <a href=") . esc("$basic_init->{'main_url'}history-account-$account.html") . qq("$ac_style>\@$account</a> );
			} else {
				$account_link .= qq( \@${account});
			}

	}


# ���t����
#my($year,$other_dates) = split(/\//,$dat,2);
#if($year eq $thisyear){ $dat = $other_dates; }

	# ���X�ԕ\�L�𒲐�
	if($ch{'word'} || $res_comma || $res_between || $omit_flag eq "2"){
		$view_no = qq(<a href="$in{'no'}.html-$no#RES">#$no</a>);
	}
	else{ $view_no = qq(#$no); }

	# �ȗ������N
	if($omitlink){
		$omitlink = qq($omitlink );
	}

	# �摜�\�����`
	if($image_data){
		my(%image) = Mebius::Paint::Image("Get-hash Justy",undef,undef,$server_domain,$realmoto,$in{'no'},$no);
			if($image{'image_ok'}){
				$image_view .= qq(<div>);
				if($image{'tail'} eq "png" && $main::device{'id'} eq "DOCOMO"){ $image_view .= qq( <a href="$image{'samnale_url'}">); }
				else{ $image_view .= qq( <a href="$image{'image_url'}">); }
				$image_view .= qq(�摜);
				$image_view .= qq(</a>);
				$image_view .= qq(</div>);
			}
	}


	# ���폜�˗��̃`�F�b�N�{�b�N�X
	if(Mebius::Report::report_mode_judge_for_res()){
		($report_check_box) = shift_jis(Mebius::Report::report_check_box_per_res({ handle_deleted_flag => $res_concept{'Deleted-handle'} , comment_deleted_flag => $comment_deleted_flag },"bbs_thread_$use_thread->{'bbs_kind'}_$use_thread->{'number'}_$no"));
	}

	if( my $message = $fillter->each_comment_fillter_on_shift_jis($com)){
		$com = $message;
	}

	if( my $message = $fillter->each_comment_fillter_on_shift_jis($nam)){
		$viewname = $message	;
	}

# ���ۂ̏����o��
$line .= qq(<div style="text-align:center;background:#ddf;border-top:solid 1px #000;">$aname$dw_mk $view_no $up_mk</div>);
$line .= qq(<div style="margin:6px 0px;">$viewname$account_link</div>);
$line .= qq(<div style="color:$color;">$com</div>);
$line .= qq(<div style="text-align:right;">$view_trip$view_id</div>);
$line .= qq(<div style="text-align:right;">$omitlink$image_view$tripory_link$edit$dat</div>);
	if($report_check_box && !$secret_mode){ $line .= qq(<div style="text-align:right;">$report_check_box</div>); }

#background:#def;

my($seal) = shift_jis_return(Mebius::BBS::Posted::last_regist_seal($use_thread->{'bbs_kind'},$use_thread->{'number'},$no));
$line .= $seal;

return($line);

}

use strict;

#-----------------------------------------------------------
# �y�[�W���������N
#-----------------------------------------------------------
sub thread_get_pagelinks_mobile{

# �錾
my($type,$inpage,$thread_resnum,$split_page,$first_page) = @_;
my($pagemove_links,$nowpage,$move,$prev_pagenum,$next_pagenum,$ryaku_cnt_mae,$after_rpage,$newpage_num);
my($nextpage_link,$prevpage_link,$newpage_link,$allpage_num,$nowrealpage_num,$moveid);
my($brandnewpage_link,$through_brandnewpage_flag,$through_firstpage_flag);
my($near_brandnewpage_flag,$near_firstpage_flag);
our(%in,$last_res);

# ���݂̃��^�[��
if($in{'No'} ne ""|| $in{'word'} ne ""){ return; }
if($thread_resnum <= $first_page && $type =~ /Top/){ return; }

	# �����N�ړ��̂��߂�ID���`
	if($type =~ /Top/){ $moveid = qq(<a id="PAGES"></a>); }

	# �ړ������N
	elsif($type =~ /Bottom/){
		$moveid = qq(<a href="#RESFORM" id="SBMENU">��</a><a href="#D$last_res" id="DBMENU">��</a> );
	}

# �ړ������N��
$move = qq(#PAGES);

# �ŐV�y�[�W�̃y�[�W�����v�Z
#$newpage_num = $res - $first_page + 1

	# ���̋L���̑S�Ẵy�[�W�����v�Z
	# ���X���� $first_page ���z���Ă��Ȃ��ꍇ�A�������Ƀy�[�W���͂P��
	if($thread_resnum <= $first_page){ $allpage_num = 1; }
	# �ŐV�y�[�W�����̂������S�Ẵ��X���i�Q�y�[�W�ڂ̍Ō�̃��X�ԁj���y�[�W�����l�Ŋ���A����ɍŐV�P�y�[�W���𑫂�)
	#$allpage_num = int(($thread_resnum-$first_page+$split_page) / $split_page);
	else{ $allpage_num = int(($thread_resnum-$first_page-1) / $split_page) + 1 + 1; }

	# ���݃A�N�Z�X���Ă���y�[�W�����v�Z
	if($inpage){ $nowrealpage_num = int($inpage / $split_page) + 1; }
	else{ $nowrealpage_num = $allpage_num; }

# ���O�̃y�[�W�A���̃y�[�W

# ���݂̎����y�[�W�ʒu���`
$nowpage = $inpage;
	if(!$inpage) { $nowpage = $thread_resnum - $split_page + 1 + $first_page; }

	# ���X���ɉ����Ĉړ������N��\������
	if($thread_resnum > $first_page){

		# �ЂƂO�̃y�[�W�����v�Z
		$prev_pagenum = $nowpage - ($nowpage % $split_page) + 1;
			if($inpage){ $prev_pagenum -= $split_page; }
			if($inpage eq ""){
				my $firstres = ($thread_resnum - $first_page + 1);
				my $before_lastres = $firstres - 1;
				$prev_pagenum = ($before_lastres-1) - (($before_lastres-1) % $split_page) + 1;
			}

		# �ЂƂ�̃y�[�W�����v�Z
		if($inpage + $split_page > $thread_resnum - $first_page){ $next_pagenum = qq(); }	# ���̃y�[�W���ŐV�y�[�W�̏ꍇ
		else{ $next_pagenum = qq(_) . ($inpage + $split_page); }							# ���ʂ́A���݂̃y�[�W�l�{�P�y�[�W�����w��

	# �ȗ�����Ă��郌�X�����v�Z
	$ryaku_cnt_mae = $nowpage - 1;

		# �O�̃y�[�W ( ���V�����y�[�W ) �ւ̃����N
		if(!$inpage){ $nextpage_link .= qq(�C�V\n); }
		else{ $nextpage_link = qq( <a href="$main::in{'no'}${next_pagenum}.html$move" accesskey="4"$main::utn2>�C�V</a>\n); }

		# ���̃y�[�W ( ���Â��y�[�W ) �ւ̃����N
		if($nowpage <= 1){ $prevpage_link = qq(�E��); }
		else{ $prevpage_link = qq( <a href="$main::in{'no'}_${prev_pagenum}.html$move" accesskey="6"$main::utn2>�E��</a>\n); }

	}

# ���y�[�W�؂�ւ������N

# �Ǐ���
my($page,$round,$second,$linkpage,$flag,$i,$count,$page_links);
my($pagemove_link,$cutlink);
my($maxlink_round) = (7);	# �����N�̍ő吔

# ���ɂ��郊���N�����v�Z
my($link_balaety) = int($maxlink_round/2);

# ���E���h��w�����`
$round = $nowrealpage_num+$link_balaety;
	# ���E���h�������Ȃ�����ꍇ�́A�Œ�y�[�W������
	if($round < $maxlink_round){ $round = $maxlink_round; }
	# ���ׂẴy�[�W�������傫���l�ł͎n�߂Ȃ��i�V�������̃y�[�W�ŁA���݂��Ȃ��y�[�W����\�����Ȃ��j
	if($round > $allpage_num){ $round = $allpage_num; }

	if($round > 1000){
		die("Perl Die! Too many page rounds '$round'");
	}

	# ���E���h���Ȃ��Ȃ�܂ŌJ��Ԃ�
	while($round > 0){

			# �ŐV�y�[�W�̃����N��\���������ǂ������L��
			if($round == $allpage_num){ $through_brandnewpage_flag = 1;  }
			if($round == $allpage_num - 1){ $near_brandnewpage_flag = 1;  }

			# �P�y�[�W�ڂ̃����N��\���������ǂ������L��
			if($round == 1){ $through_firstpage_flag = 1; }
			if($round == 1 + 1){ $near_firstpage_flag = 1; }

			# �����N����y�[�W�̓��e�l���`
			if($round == $allpage_num){ }
			else{ $linkpage = qq(_) . ( ( ( $round * $split_page ) - $split_page ) + 1); }

			# �����N�s���`
			if($round == $nowrealpage_num){ $page_links .=  qq($round\n); }
			else{ $page_links .=  qq(<a href="$in{'no'}$linkpage.html$move"$main::utn2>$round</a>\n); }

		$count++;	# �J�E���g���͑����Ă���
		$round--;	# ���E���h���͌����Ă���

			# �\���ő吔���z������I��
			if($count >= $maxlink_round){ last; }

	}

	# �ŐV�y�[�W�ւ̃����N���Ȃ���Βǉ�
	if(!$through_brandnewpage_flag){
		$brandnewpage_link .=  qq(<a href="$in{'no'}.html$move"$main::utn2>$allpage_num</a>\n);
			if(!$near_brandnewpage_flag){ $brandnewpage_link .=  qq(.. ); }
	}

	# �P�y�[�W�ڂւ̃����N���Ȃ���Βǉ�
	if(!$through_firstpage_flag){
		if(!$near_firstpage_flag){ $page_links .=  qq(.. ); }
		$page_links .=  qq(<a href="$in{'no'}_1.html$move"$main::utn2>1</a>\n);
	}



# �����N���`
$pagemove_links = qq(<hr$main::xclose><div style="font-size:x-small;">$moveid$nextpage_link$brandnewpage_link$page_links$cutlink$prevpage_link</div>);

# ���^�[��
return($pagemove_links);

}

no strict;


#-----------------------------------------------------------
# ���X�Ԏw��̏ꍇ�A�����N�\��
#-----------------------------------------------------------
sub resnumber_link{

# �Ǐ���
my($round,$No_start,$No_end,$round_start) = @_;
my($line,$next,$before,$r_page,$start,$formar_move,$accesskey4,$accesskey5,$accesskey6);

# ���^�[��
if(!$ch{'No'}){ return; }

# �A�N�Z�X�L�[
if($round == 1){
$accesskey4 = qq( accesskey="4");
$accesskey6 = qq( accesskey="6");
}

$before = $No_start - 1;
$next =  $No_end + 1;

# ���y�[�W�ւ̃����N
if($round == 1){ $round_start = $No_start; }
if($round == 2){ $round_start = $No_end + 1; }
$r_page = qq(_) . ( ($round_start-1) - ( ($round_start-1) % $kpage) + 1);
if($round_start >= $res - $kfirst_page + 1){ $r_page = undef; }
if($round_start eq "0"){ $r_page = undef; }

# ���y�[�W�̈ړ������N
$formar_move = qq(#S$round_start);
if($No_end >= $res && $round == 2){ $formar_move = qq(#C); }
if($round_start eq "0"){ $formar_move = qq(#S0); }

# ���`
#if($round == 2){ $line .= qq(<hr$xclose>); }

	# ���i�V�j
	if(!$main::bot_access){
			if($No_end >= $res){ $line .= qq( <a href="#RESFORM"$accesskey4>�C��</a>); }
			else{ $line .= qq( <a href="$in{'no'}.html-$next#RES"$accesskey4>�C��</a>); }
	}

	# ��
	if($round == 1){ $line .= qq( <a href="$in{'no'}$r_page.html$formar_move">�D��</a>); }
	elsif($round == 2){ $line .= qq( <a href="$in{'no'}$r_page.html$formar_move">�D��-��</a>); }

	# ��i�Áj
	if(!$main::bot_access){
			if($No_start <= 0){ $line .= qq( �E��); }
			else{ $line .= qq( <a href="$in{'no'}.html-$before#RES"$accesskey6>�E��</a>); }
	}

# �V
$line .= qq( <a href="$in{'no'}.html#RES">�ŐV</a>);

# ���`
#if($round == 1){ $line .= qq(<hr$xclose>); }

# �߂����`
our $kback_url = "$in{'no'}$r_page.html$formar_move";

$line = qq(<div style="font-size:small;">$line</div>);

# �߂��O���[�o���ϐ���ݒ�
our $kback_url_tell = qq($in{'no'}$r_page.html$formar_move);

return($line);

}


#-----------------------------------------------------------
# �����ˁI�t�@�C�����J��
#-----------------------------------------------------------
#sub thread_viewsupport_mobile{

#my($count);

# �����ˁI�t�@�C�����J��
#open(SUPPORT_IN,"<","$main::bbs{'data_directory'}_crap_count_${moto}/$in{'no'}_cnt.cgi");
#my $cnt_top = <SUPPORT_IN>;
#($count) = split(/<>/,$cnt_top);
#$support_top2 = <SUPPORT_IN>;
#close(SUPPORT_IN);
#if($count){ $pri_count = "($count)"; }

#}



#-----------------------------------------------------------
# �L���������擾
#-----------------------------------------------------------
sub thread_get_memo_mobile{

# �Ǐ���
my($line,$i,$return_line);
our($kborder_top_in);

# �L��������\�����Ȃ��ꍇ
if($key eq "3" || $in{'No'} ne ""){}

	# �L��������\������ꍇ
	elsif($memo_body ne ""){

			foreach(split(/<br>/,$memo_body)){

				# ���s���l�߂�
				if($_ eq ""){ next; }

					# �R�����g�A�E�g�łȂ���΁A�����{���Ƃ��Ēǉ�
					unless($_ =~ /^\/\//){
						($_) = &kauto_link("Memo",$_,$main::in{'no'});
						$line .= "$_<br$xclose>";
						$i++;
					}

				# �`�s�ȏ�͏ȗ�
				if($i > 3){ $line .= qq(�i<a href="$script?mode=kview&amp;no=$in{'no'}&amp;r=memo&amp;type=oview" rel="nofollow">�c�ȉ���</a>�j); last; }
			}

			# �ŏI�ҏW�҂̂h�c�C�g���b�v������
			if($dd5){ ($dd5_name,$dd5_id,$dd5_eml2) = split(/=/,$dd5); }
			if($dd5_eml2){$dd5_trip = "��$dd5_eml2";}

			# ���`
			if($in{'r'} ne ""){ $line = ""; }
			$return_line .= qq(<div style="text-align:center;background:#ddf;$kborder_top_in">);
			$return_line .= qq(<a href="$in{'no'}_memo.html" rel="nofollow">����</a></div>);
			$return_line .= qq(�ŏI�F $dd5_name$dd5_trip��$dd5_id<br$xclose>$line);

	}

	# �L���������Ȃ��ꍇ
	else{
		$return_line .= qq(<div style="text-align:center;background:#ddf;$kborder_top_in">);
		$return_line .= qq(<a href="$in{'no'}_memo.html" rel="nofollow">����</a></div>�܂�����܂���B);
	}

	# �Ō�̐��`
	if($line){ $return_line = qq(<div style="$kfontsize_xsmall_in">$return_line</div>); }

return($return_line);


}

#-----------------------------------------------------------
# ���X�Ԕ���
#-----------------------------------------------------------
#sub thread_check_resnumber_mobile{

# �Ǐ���
#my($hit,$No_start,$No_end);
#my($res) = @_;

# No.0 �̕\���t���O

	# �y�[�W������
#	if($in{'r'} eq "all"){ }
#	elsif($in{'r'} ne "" && ($in{'r'} =~ /([^0-9])/ || $in{'r'} <= 0 || $in{'r'} > $res) ){ &error("�y�[�W���̎w�肪�ςł��B"); }
#	if($ch{'word'}){ $hit++; }
#	if($ch{'No'}){ $hit++; }
#	if($ch{'r'}){ $hit++; }
#	if($hit >= 2){ &error("���[�h�͈�܂ł����I�ׂ܂���B","404 NotFound"); }

	# ���X�Ԕ���
#	if($in{'No'} eq ""){ return; }

	# �e��G���[
#	if($in{'No'} !~ /\d/){ &error("���X�Ԃ̎w�肪�ςł��B���p���� ( 0-9 ) ��K������Ă��������B "); }
#	if($in{'No'} =~ /[^0-9\-,]/){ &error("���X�Ԃ̎w�肪�ςł��B���p���� ( 0-9 ) �A ���p�J���} ( , ) �A ���p�n�C�t�� ( - ) �����Ŏw�肵�Ă��������B "); }
#	if($in{'No'} =~ /\-/ && $in{'No'} =~ /\,/){ &error("���X�Ԃ̎w�肪�ςł��B���p�J���} ( , ) �� ���p�n�C�t�� ( - ) �͈ꏏ�Ɏg���܂���B"); }
#	if(($in{'No'} =~ s/\-/$&/g) >= 2){ &error("���X�Ԃ̎w�肪�ςł��B���p�n�C�t�� ( - ) �͂P���������g���܂���B"); }

	# ���C���w��
#	if($in{'No'} =~ /-/) {
#		($No_start,$No_end) = split(/-/, $in{'No'}, 2);
#		if($No_start eq "" || $No_end eq ""){ &error("���X�Ԃ̓n�C�t���ŋ�؂��Đ��������͂��Ă��������B"); }
#		if($No_start > $No_end){ ($No_start,$No_end) = ($No_end,$No_start); }
#		if($No_end - $No_start > $p_page){ $No_end = $No_start + $p_page -1; }
#		$res_between = 1;
#	}

	# �J���}�w��
#	elsif($in{'No'} =~ /,/){
#		$res_comma = 1;
#		$No_start = $res;
#		foreach ( split(/,/, $in{'No'}) ) {
#		if($_ < $No_start){ $No_start = $_; }
#		if($_ > $No_end){ $No_end = $_; }
#		}
#	}

	# �P��w��
#	elsif($in{'No'} ne ""){
#		$No_start = $No_end = $in{'No'};
#		$res_one = 1;
#	}

	# ���X�w�肪�傫������ꍇ
#	if($No_end > $res){ $No_end = $res; }

	# �O�͍ŏ��ɏ����Ȃ�
#	if($No_start =~ /^0([0-9+])/ || $No_end =~ /^0([0-9+])/){ &error("���X�Ԃ̎w�肪�ςł��B�ŏ��� 0 �͏����܂���B"); }

#return($No_start,$No_end);

#}

#-----------------------------------------------------------
# �^�C�g����`
#-----------------------------------------------------------
sub thread_set_title_mobile{

# �錾
our($realmoto);
my($server_domain) = Mebius::server_domain();

# �^�C�g����`
$sub_title = $sub;

	# �y�[�W��
	if($in{'r'} ne ""){
		my $page = int($in{'r'} / $kpage) + 1;
		$sub_title= "$page�� | $sub";
		my $pc_page = ($in{'r'} - 1) - ( ($in{'r'} - 1) % $p_page ) + 1;
		if($in{'r'} >= $res - $pfirst_page+1){ $divide_url = "http://$server_domain/_$realmoto/$in{'no'}.html"; }
		else{ $divide_url = "http://$server_domain/_$realmoto/$in{'no'}_${pc_page}.html"; }
	}

	# ���X�ԕ\��
	elsif($in{'No'} ne ""){
		$sub_title= "$in{'No'} | $sub";
		$divide_url = "http://$server_domain/_$realmoto/$in{'no'}.html-$in{'No'}";
	}

	# �L��������
	elsif($ch{'word'}){
		$sub_title= "�h$in{'word'}�h - $sub";
		my($encword) = Mebius::Encode("",$in{'word'});
		$divide_url = "http://$server_domain/_$realmoto/?mode=view&no=$in{'no'}&word=$encword";
		$divide_url =~ s/mode=kview/mode=view/;
	}
	# �P�v�I���_�C���N�g
	else{
		# �^�C�g����`
		$sub_title = $sub;
		$divide_url = "http://$server_domain/_$realmoto/$in{'no'}.html";
	}

	# ���_�C���N�g�ŐU�蕪��
	#if($device_type eq "desktop" && $divide_url){ &divide("$divide_url","desktop"); }

}

use strict;

#-----------------------------------------------------------
# ���C���L���Łu�T�u�L���f�[�^�v���擾
#-----------------------------------------------------------
sub thread_get_subdata_mobile{

my($line,$sub_nofollow);
our($moto,%in);

my($thread) = Mebius::BBS::thread_state($in{'no'},"sub${moto}");
my($subres,$subkey) = ($thread->{'res'},$thread->{'key'});



	if($subres <= 0){ $sub_nofollow = qq( rel="nofollow"); }

return($subkey,$subres,$sub_nofollow);

}

no strict;

#-------------------------------------------------
# �t�H�[����
#-------------------------------------------------
sub kform2 { require "${int_dir}k_form2.pl"; &bbs_thread_form_mobile(); }


1;
