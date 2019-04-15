
use strict;
use Mebius::Paint;
use Mebius::Page;
use Mebius::BBS;
use Mebius::Text;
use Mebius::Fillter;
#use Mebius::BB0::Crap;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# �y�[�W�{��
#-----------------------------------------------------------
sub bbs_view_thread{

my($param) = Mebius::query_single_param();
my($my_use_device) = Mebius::my_use_device();

# �ᔽ��
Mebius::Report::report_mode_junction({ });

	if($param->{'r'} eq "all"){
		my $bbs_thread = new Mebius::BBS::Thread;
		my $thread_url = $bbs_thread->data_to_url({ bbs_kind => $param->{'moto'} , thread_number => $param->{'no'} });
		Mebius::redirect($thread_url,301);
		exit;
	# ���[�h�U�蕪��
	} elsif($my_use_device->{'type'} eq "Mobile"){
		my($init_directory) = Mebius::BaseInitDirectory();
		require "${init_directory}k_view.pl";
		bbs_view_thread_mobile(@_);
	}
	else{
		bbs_view_thread_desktop(@_);
	}

}

#-----------------------------------------------------------
# �y�[�W���{��
#-----------------------------------------------------------
sub bbs_view_thread_desktop{

# �錾
my($use) = @_;
my($topdata_handler,$top2,$use_thread,$main_thread,$sub_thread);
my($my_use_device) = Mebius::my_use_device();
my($init_directory) = Mebius::BaseInitDirectory();
my($init_bbs) = Mebius::BBS::init_bbs_parmanent_auto();
my($param) = Mebius::query_single_param();
my $bbs_object = Mebius::BBS->new();
my $bbs_thread = new Mebius::BBS::Thread;
our(%in,%done,$css_text,$concept,$noads_mode,$realmoto,$moto,$cookie,$nocview_flag,$subtopic_mode,$subtopic_link,$mode,$m_max,$deleted_text);


# �����`�F�b�N
if($param->{'no'} =~ /\D/){ &error("�L���i���o�[�̎w�肪�ςł��B�����݂̂��w�肵�Ă��������B"); }
my $thread_number = $param->{'no'};

	# ���_�C���N�g
	if($in{'dl'} == 1){ Mebius::Redirect("","/_$moto/$param->{'no'}.html","301"); }

# ��d�������֎~
if($done{'pageview'}){ return; }
$done{'pageview'} = 1;


	# ��CSS
	{

			if(Mebius::Admin::admin_mode_judge()){
				$main::css_text .= qq(
				div.reszone{padding:0em 0.5em;word-wrap:break-word;text-align:right;}
				input.console{font-size:100%;background:#fff;}
				input.disabled{background:#ddd !important;border-color:#ddd !important;}
				input.backurl{background:#5fa;border-color:#5fa;}
				.TSEARCH{background:#ddd;border:solid 1px #000;text-align:left;padding:0.3em 0.5em;}
				div.tag{margin:1em;}
				img.paint_image{width:120px;height:120px;}
				div.image_deleted{color:#f00;font-size:90%;margin:1em 0em;}
				div.res_margin{margin:0.5em 0em 0.5em 20%;padding:0.2em 1em;}
				div.reporter{text-align:left;background:#afa;}
				div.deleted_image{padding:0.5em;margin:0.5em;color:#f00;border:solid 1px #f00;}
				div.data2{line-height:2.0;}
				div.div2{margin-top:1em;}
				);
			}

		# ���ʂ�CSS
		$main::css_text .= qq(.ac{margin-left:0.7em;});

			# �X�}�t�H�ł�CSS
			if($my_use_device->{'smart_flag'}){
				#$main::css_text .= qq(.thread_subject{font-size:120%;margin:0em;});
				$main::css_text .= qq(.vtitle{font-size:100%;});
				$main::css_text .= qq(.body1{width:100%;});
				$main::css_text .= qq(.d_ryaku{padding:0.25em 0.5em 0.25em 0.5em;});
				$main::css_text .= qq(div.date{margin-top:0.5em;});
				$main::css_text .= qq(.ads_first_view{margin:0.5em 0em;});

			}
			# �f�X�N�g�b�v�ł�CSS
			else{
				$main::css_text .= qq(.d_ryaku{padding:0.25em 1.5em 0.75em 1.5em;}\n);
				$main::css_text .= qq(.thread_subject{font-size:190%;margin:0em;}\n);
				$main::css_text .= qq(.vtitle{font-size:130%;}\n);
			}
	}

	# �L���f�[�^��ǂݍ��� �i�T�u�L���j
	if(Mebius::BBS::sub_bbs_judge_auto()){
		require "${init_directory}part_subview.pl";
		($main_thread,$sub_thread) = thread_sub_base();
		$use_thread = $sub_thread;
	}

	# �L����ǂݍ��� (���ʋL���j
	else{

		($main_thread) = Mebius::BBS::thread_state( $in{'no'} , $moto );

		$use_thread = $main_thread;

			# CCC - 2010/11/16 - �ߋ����O�Ȃ̂ɁA�ߋ����O���������t���Ȃ��ꍇ�A�V�ߋ����O�Ɉڍs
			#if($main_thread->{'key'} eq "3" && $main_thread->{'concept'} !~ /Be-pasted/ && !Mebius::BBS::sub_bbs_judge_auto()){
			#	Mebius::AccessLog(undef,"Be-past-since-2010");
			#	Mebius::BBS::BePastThread("Old-thread",$main::realmoto,$thread_number);
			#}

			# 2012/8/28 (��)
			# �ߋ����O���j���[�ɒǉ�����Ă��Ȃ����������̃��O�C��
			#if($main_thread->{'key'} eq "3" && !Mebius::BBS::sub_bbs_judge_auto() && $main_thread->{'bepast_time'} > 1346158490 - (5*30*24*60*60) && $main_thread->{'bepast_time'} < 1346158490 && $main_thread->{'concept'} !~ /Fix-2012\.08\.29\.15/){

			#	Mebius::BBS::BePastThread("Fix-2012.08.29.15",$main::realmoto,$thread_number);
			#	Mebius::AccessLog(undef,"Be-past-since-2012");
			#}

			# ���C���L���̏ꍇ�A�T�u�L���f�[�^��ǂݍ���
			if($init_bbs->{'use_sub_thread'}){
				#($sub_thread) = Mebius::BBS::thread_state($in{'no'},"sub$moto");
				#($subkey,$subres,$sub_nofollow) = Mebius::BBS::thread();
					#our $subkey = $sub_thread->{'key'};
					#our $subres = $sub_thread->{'res'};
					if($main_thread->{'sub_thread_res'} <= 0){ our $sub_nofollow = qq( rel="nofollow"); }
			}

	}

$bbs_thread->read_on_history($use_thread);

	# 404��Ԃ��ꍇ
	if(!$main_thread->{'f'}){ main::error("���̋L���͑��݂��܂���B"); }

# �\���^�C�v����
our($No_start,$No_end,$res_comma) = thread_check_resnumber($use_thread->{'res'});

	# �L�[����
	if(!Mebius::Admin::admin_mode_judge()){
			if(($main_thread->{'key'} eq "7" && time >= $main_thread->{'delete_reserve_time'}) || $main_thread->{'key'} eq "6" || $main_thread->{'key'} eq "4"){
				require "${init_directory}part_thread_status.pl";
				thread_get_deletelock("HEAVY DESKTOP",$main_thread,$use_thread);
			}
			elsif($main_thread->{'key'} eq "7"){ require "${init_directory}part_thread_status.pl"; our($deleted_text) = thread_get_deletelock("LIGHT DESKTOP",$main_thread); }
	}


	if(time < 1385108717 + 30*24*60*60){
		my $insert_or_update = $bbs_thread->thread_data_to_multi_data_for_status($use_thread);
		$bbs_thread->renew_multi_status($insert_or_update);
	}

	# CCC�X�y�V�����폜 �̂̃L�[�𔭌�
	#if($main_thread->{'key'} eq "6"){ Mebius::send_email("To-master",undef,undef,qq(���X�y�V�����폜�L�� $main::selfurl)); }

	# ���I�A�V���b�L���O�ȕ\��
	if($main_thread->{'sexvio'}){
		require "${init_directory}part_sexvio.pl";
		sexvio_check($main_thread->{'sexvio'});
	}

# ���e�ɂ���čL������
require "${init_directory}part_adscheck.pl";

my($adscheck_flag) = main::adscheck($use_thread->{'subject'},$use_thread->{'zero_comment'});

	my($subject_fillter_error) = Mebius::Fillter::fillter_and_error(utf8_return($use_thread->{'subject'}),utf8_return($use_thread->{'zero_comment'}));

	if($main_thread->{'key'} eq "7"){ $noads_mode = 1; }

	# ���X���ő��B�������X���b�h�͋L�^
	if($use_thread->{'res'} >= $m_max && !$adscheck_flag && !$main_thread->{'sexvio'}){
		Mebius::BBS::thread({ Renew => 1 , TypeMaxResRecord => 1 },$realmoto,$thread_number);
	}

# �L���̑I��
thread_ads_set("",$main_thread->{'key'});

# �^�C�g����`�A�A�N�Z�X�U�蕪��
my($BCL) = thread_set_title($main_thread);

	# �y�[�W�r���[�̌Ăяo���A�J�E���g
	if(!Mebius::Switch::light() && !Mebius::Switch::thread_light()){
		require "${init_directory}part_pv.pl";
		our($pageview) = do_pv({ TypeRenew => 1 ,TypeAddRanking => 1 },$thread_number,$moto);
	}

	# �֘A�L�����쐬
	#if( ($cookie && !$nocview_flag && (Mebius::alocal_judge() || rand(5) < 1) && !$main_thread->{'sexvio'} && ($main_thread->{'key'} eq "1" || $main_thread->{'key'} eq "5")) ){
	#	require "${init_directory}part_kr.pl";
	#	open_kr("VIEW",$realmoto,$thread_number,$main_thread->{'sub'});
	#}

# �i�r�Q�[�V���������N���擾
my $move_side_links_flag = 1 if(!$main::subtopic_mode);
my($navi_links) = shift_jis(Mebius::BBS::thread_navigation_links($use_thread,{ Top => 1 , MoveSideLinks => $move_side_links_flag }));

	# ��
	my($obi_line);
	if($main_thread->{'key'} eq "4" || $main_thread->{'key'} eq ""){ $obi_line.=  qq(<a name="c"></a>); }
	if($main_thread->{'key'} eq "0" && !Mebius::Admin::admin_mode_judge()){
		require "${init_directory}part_thread_status.pl";
		($obi_line) .= thread_status_lock("LOCK DESKTOP",$main_thread->{'delete_data'},$main_thread->{'lock_end_time'});
	}


	# ���X�ԕ\���̏ꍇ�ɁA�L���̕\���L�������肷��
	if(Mebius::BBS::Thread->no_ads_judge_on_splited_res()){
		$noads_mode = 1;
	}

# ���X�擾
my($res_line,$tsearch_line1,$tsearch_line2) = thread_round_res($use_thread,$main_thread);

	#if($param->{'ajax'}){
	#	print "Content-type:text/html\n\n";
	#	utf8($res_line);
	#	print $res_line;
	#	exit;
	#}

	# �폜�˗����[�h�̏ꍇ�A�t�H�[����ǉ�
	if($param->{'single_reason_report_mode'}){

			if($ENV{'REQUEST_METHOD'} eq "GET"){
						if($param->{'No'}){
							my $thread_url_with_number = Mebius::BBS::thread_url_number($use_thread->{'number'},$use_thread->{'bbs_kind'},$param->{'No'});
							Mebius::redirect($thread_url_with_number,301);
							exit;
						} else {
							Mebius::redirect("$use_thread->{'url'}",301);
							exit;
						}
			}

		($res_line) = Mebius::Report::around_report_form($res_line,"bbs_thread_$use_thread->{'bbs_kind'}_$use_thread->{'number'}_$param->{'No'}",{ OnlyTarget => 1 });
	} else {
		($res_line) = Mebius::Report::around_report_form($res_line,"bbs_thread_$use_thread->{'bbs_kind'}_$use_thread->{'number'}");
	}

# No.0���擾
my($zero_line);

	if(Mebius::Admin::admin_mode_judge()){
		($zero_line) = shift_jis(Mebius::Admin::bbs_thread_admin_console(undef,$realmoto,$thread_number,$use_thread));
	} else {
		($zero_line) = thread_get_zero($_[0],$use_thread,$main_thread,$sub_thread);
	}
	if($zero_line){
		$zero_line = qq(<div class="thread_body bbs_border" id="S0">$zero_line</div>);
	}

	# 404��Ԃ��ꍇ
	if($main_thread->{'key'} eq ""){ main::error("���̋L���͑��݂��܂���B"); }

	# �҂����Ԃ��`�F�b�N
	if($mode ne "form" && !Mebius::Admin::admin_mode_judge() ){
		require "${init_directory}part_waitcheck.pl";
		our($wait_textarea) = get_nowcharge_res("VIEW");
	}

# ���e�t�H�[�����擾
require "${init_directory}part_resform.pl";
my($resform_line) = bbs_thread_form({ GetMode => 1 , ResMode => 1 , use_thread => $use_thread , main_thread => $main_thread , sub_thread => $sub_thread });


# �����o��
my $view_line = qq(
$navi_links
$obi_line
<article>$zero_line</article>
$tsearch_line1
<article>$res_line</article>
$tsearch_line2
);

	

	# ���e�t�H�[���t�H�[��
	if(!Mebius::Report::report_mode_judge() && !$use->{'Preview'}){
		$view_line .= $resform_line;
	}

	# �����̂܂܏o�͂���ꍇ
	if(!$use->{'Preview'}){

		#my $bbs_thread = new Mebius::BBS::Thread;
		#my $canonical = $bbs_thread->canonical();

			# �t�b�^
			if($my_use_device->{'smart_flag'} || Mebius::alocal_judge()){
				$bbs_object->print_html_all($view_line,{ BCL => $BCL , no_ads_flag => $noads_mode , ReadThread => 1 , read_thread_res_number => $use_thread->{'res'} , Jquery => 1 , BeforeUnload => 1 , javascript_files => ['jquery.flicksimple']});
			} else {
				$bbs_object->print_html_all($view_line,{ BCL => $BCL , no_ads_flag => $noads_mode , ReadThread => 1 , read_thread_res_number => $use_thread->{'res'} });
			}

		exit;

	}


$view_line;


}



#-----------------------------------------------------------
# ���ʂ̃��X�\��
#-----------------------------------------------------------
sub thread_round_res{

# �Ǐ���
my $use_thread = shift;
my $main_thread = shift;
my @thread_data = @{$use_thread->{'all_line'}};
my $res = $use_thread->{'res'};
my($before_rpage,$cutres,$move,$last_flag,$round,$reads_hit_flag,$res_flag,$file,$resarea_dw,$resarea_up);
my($res_start,$res_end,$res_line);
my($my_cookie) = Mebius::my_cookie_main_logined();
my($init_directory) = Mebius::BaseInitDirectory();
my($param) = Mebius::query_single_param();
our($keep_regist,%in,$p_page,$body_javascript,$No_start,$No_end,$pfirst_page,$tsearch_hit,$res_comma);

	if(@thread_data < 1){ return(); }

# �v�f�̒���
our $reshit_flag = 0;
our $resads_hit_flag = 0;

	# �����ߑ��r��
	#if($res > $m_max) { $res = $m_max; }
	if($res > 10000) { $res = 10000; }

	# �������[�h�̏���
	if(exists $in{'word'}){

		# ��荞��
		require "${init_directory}part_tsearch.pl";
		my($message) = tsearch_check_keyword($in{'word'});
		$body_javascript = qq( onload="document.UM.word.focus()");

			# �q�b�g���Ȃ������ꍇ�Ȃ�
			if($message){
				$round++;
				$res_line .= qq(<div class="d">$message</div>);
				$res_flag = 0;
			}
	}

$res_start = $res - $pfirst_page + 1;
$res_end = $res;
	if($in{'r'} eq "all"){ $res_start = "";  }
	elsif($in{'No'} ne ""){
			if(Mebius::Admin::admin_mode_judge() && $in{'No'} =~ /^[0-9]+$/){
				$res_start = $No_start-50;
				$res_end = $No_start+50;
					if($res_start <= 0){ $res_start = 1; }
			} else {
				($res_start,$res_end) = ($No_start,$No_end);
			}
	}
	elsif($in{'r'} ne ""){
		$res_start = $in{'r'};
		$res_end = $in{'r'} + $p_page - 1;

			# �P�y�[�W�ڂƂQ�y�[�W�ڂ̏d������\�����Ȃ��悤��
			if((Mebius::BBS::InitThreadDupulicationPage()) eq "Deny"){
					if($in{'r'} >= $res - $pfirst_page - $p_page){ $res_end = $res - (($pfirst_page + 1 - 1)  % $p_page) + 1 - 1; }
			}
	}		
	elsif($in{'word'} ne ""){ ($res_start) = ""; }


	# ���X�����̕\��
	if($res_flag ne "0"){

		# �g�b�v�f�[�^�𖳎�����
		shift @thread_data;

		# No.0 �𖳎�����
		if(!exists $in{'No'} && !exists $in{'word'}){ shift @thread_data; }

			# �t�@�C����W�J
			foreach(@thread_data) {

				# �Ǐ���
				chomp;
				my @splited_data = split(/<>/);
				my($no,undef,$nam,$trip,$com,$dat,$ho,$id,undef,undef,undef,$deleted,$account,$image_data,$res_concept,$regist_time2) = @splited_data;
				my($res_line_core);

					# ��d���X / �o�O���m�v
					#if($keep_regist eq "$regist_time2->$com" && time < ($regist_time2 + (3*24*60*60))){
					#	Mebius::AccessLog(undef,"Double-res","( ���e�����F $dat ) ${main::jak_url}$main::realmoto.cgi?mode=view&no=$in{'no'}&No=$no#RESNUMBER");
					#}
				$keep_regist = "$regist_time2->$com";

					# �A�J�E���g��\���̏ꍇ
					my $use_account = $account;
					if($res_concept =~ /Hide-account/){ $use_account = undef; }

					# ���X�����S��������Ă���ꍇ
					#if($res_concept =~ /Vanished/){
					#	next;
					#}

					# �M�����폜����Ă���ꍇ
					#if($res_concept =~ /Deleted-handle/){ $nam = qq(�폜�ς�); $trip = undef; }

					# ���X�I��
					if($no > $res_end){ last; }

					# �n�C�t����؂�
					if($no < $res_start && ($no != 0 || exists $in{'No'})){ next; }

					# �J���}��؂�
					if($res_comma){
						my($flag);
							foreach (split(/,/, $in{'No'})) {
									if ($no eq $_) { $flag = 1; last; }
							}
									if(!$flag){ next; }
					}

					if($deleted eq ""){ $resads_hit_flag++; }

					# �Ȉ�ID�t�B���^
					if($my_cookie->{'id_fillter'} || $my_cookie->{'account_fillter'}){
						my($filled_flag_id) = Mebius::BBS::Fillter_id("",$my_cookie->{'id_fillter'},$id);
						my($filled_flag_account) = Mebius::BBS::Fillter_account("",$my_cookie->{'account_fillter'},$use_account);
							if($filled_flag_id || $filled_flag_account){ next; }
					}

					if(Mebius::Admin::admin_mode_judge()){
						($res_line_core) = shift_jis(Mebius::BBS::Admin::res_core({ },$use_thread,$no));
					} else {
						($res_line_core) = thread_res_core({ absolute_date_flag => $param->{'No'} } , \@splited_data, $use_thread); 
					}

					# �\��������e������ꍇ
					if($res_line_core){

							# ������
							if($round >= 1){ $res_line .= qq(<hr>\n); }

						$reshit_flag++;
						$round++;
						$res_line .= $res_line_core;
					}

			}

	}

	# �q�b�g���Ȃ������ꍇ
	if(!$reshit_flag && (exists $in{'No'} || exists $in{'r'}) ){

			# ���_�C���N�g����ꍇ
			if($main::in{'r'} =~ /^([0-9]+)$/){
				Mebius::Redirect(undef,"http://$main::server_domain/_$main::realmoto/$main::in{'no'}.html#S$main::in{'r'}");
			}
			# �G���[���o���ꍇ
			else{ &error("�\\���ł�����e������܂���B"); }
	}

	if($res_flag ne "0" && !$reshit_flag && exists $in{'word'}){ $round++; $res_line .= qq(<div class="d">�q�b�g���܂���ł����B�L�[���[�h��ς��Č������Ă��������B</div>); }

# �����t�H�[��
my($tsearch_line2) .= get_tsearch($resads_hit_flag,"dw",$use_thread,$main_thread);
my($tsearch_line1) .= get_tsearch($resads_hit_flag,"up",$use_thread,$main_thread) if($round);

	# �㉺�̃��X�g��ǉ�
	if($round){ ($res_line) = thread_get_resarea($res_line,$use_thread); }

	# �Ǘ����[�h�̃t�H�[��
	if(Mebius::Admin::admin_mode_judge()){
		$res_line = qq(
		<form class="nomargin" action="" method="post" name="PostListFrm2">
		<input type="hidden" name="mode" value="admin">
		<input type="hidden" name="moto" value=").e($param->{'moto'}).qq(">
		<input type="hidden" name="control_type" value="res">
		<input type="hidden" name="past" value="0">
		<input type="hidden" name="no" value=").e($use_thread->{'number'}).qq(">
		<input type="hidden" name="action" value="view">
		<input type="hidden" name="job" value="del">
		$res_line
		</form>
		);
	}



$res_line,$tsearch_line1,$tsearch_line2;

}


#-----------------------------------------------------------
# �㉺�̃��X�g��ǉ�
#-----------------------------------------------------------
sub thread_get_resarea{

my($line_middle) = shift;
my $use_thread = shift;
my($my_use_device) = Mebius::my_use_device();
my $res = $use_thread->{'res'};
my($line);
our(%in,$p_page,$pfirst_page,$resads_hit_flag,$ads_dw,$ads_dw_smart);

# ���X��G���A
$line .= qq(<div class="thread_body bbs_border" id="RES">);

	# �u�O�̃y�[�W�ցv�̃����N���擾
	if($in{'No'} ne "" || exists $in{'word'}){

	} else {
		my($page_move_links) = shift_jis(Mebius::BBS::ThreadPreviewPage(undef,$main::in{'no'},$main::in{'r'},$res,$p_page,$pfirst_page,$use_thread->{'bbs_kind'}));
		$line .= $page_move_links; 
	}

	# ���X���ӂ̃����N
	if(($in{'No'} ne "" || exists $in{'word'}) && !Mebius::Admin::admin_mode_judge()){ ($line) .= thread_resaround_links($use_thread); }

$line .= qq();

$line .= $line_middle;

	# ���^�[��
	if(exists $in{'No'} || exists $in{'word'}){

	} elsif ($in{'r'}){
		my ($move) = Mebius::BBS::ThreadNextPage(undef,$main::in{'no'},$main::in{'r'},$res,$p_page,$pfirst_page,$use_thread->{'bbs_kind'});
		shift_jis($move);
		($line) .= qq(<br>) . $move;
	}

$line .= qq();

	if($resads_hit_flag){ $line .= qq($ads_dw); }
	if(($in{'No'} ne "" || exists $in{'word'}) && !Mebius::Admin::admin_mode_judge()){ ($line) .= qq(<br>) . thread_resaround_links($use_thread); }

	if($res >= 0 || $in{'No'} ne "" || exists $in{'word'}){ $line .= qq(</div>\n); }
	if($resads_hit_flag){ $line .= qq($ads_dw_smart); }

return($line);

}


#-----------------------------------------------------------
# No.0 ���擾
#-----------------------------------------------------------
sub thread_get_zero{

# �錾
my $type = shift;
my $use = $type if(ref $type eq "HASH");
my $use_thread = shift;
my $main_thread = shift;
my $sub_thread = shift;
my(%relay_type); foreach(split(/\s/,$type)){ $relay_type{$_} = 1; } # �����^�C�v��W�J
my($line,$view_date,$view_sub,$tag_line,$kr_view,$support_comment_form,$report_line,$sorcial_line,$related_line,$viewmemo);
my($my_real_device) = Mebius::my_real_device();
my($my_use_device) = Mebius::my_use_device();
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my $sub = $use_thread->{'sub'};
my $key = $use_thread->{'key'};
my($param) = Mebius::query_single_param();

our($concept,$moto,%in,$ads_up,$ads_thread_right,$subtopic_mode,$realmoto,$head_title,$deleted_text,$sexvio_text,$mytopic_flag,$ads_first_view);

	# ���^�[��
	if(exists $in{'word'} || (exists $in{'No'}  && !Mebius::Admin::admin_mode_judge())){ return; }

	# �L���������Ă���ꍇ
	if($use_thread->{'f'} && $use_thread->{'zero_comment'} eq ""){
			if(rand(1) < 1 && !$subtopic_mode){
				Mebius::send_email("To-master",undef,"�L���f�[�^�����H","${main::jak_url}$realmoto.cgi?mode=view&no=$in{'no'}\n\nReferer: $ENV{'HTTP_REFERER'}\r\rAgent: $ENV{'HTTP_USER_AGENT'}");
				Mebius::return_backup($use_thread->{'file'});
			}
	}

	# �薼
	# �X�}�t�H��
	if($my_use_device->{'smart_flag'}){
		($sub) = Mebius::Text::SmartTitle($sub);
	}

	# �^�C�g���̕\��
	if($in{'r'} eq "" && $in{'No'} eq "" && $ENV{'REQUEST_METHOD'} eq "GET"){
		$view_sub = qq(<h1 class="thread_subject inline" style="color:$use_thread->{'zero_color'};">$sub</h1> );
	} else {
		$view_sub = qq(<h1 class="thread_subject inline"><a href="$in{'no'}.html"style="color:$use_thread->{'zero_color'};">$sub</a></h1>);
	}

# �i�r�G���A
my($navi_line) .= thread_navi_zero($use,$use_thread,$main_thread,$sub_thread);

	# �����ˁI��̃R�����g
	if($use->{'CrapDone'}){
		($support_comment_form) = thread_support_comment_form(undef);
	}
	elsif($use->{'ThreadCheckDone'}){
		($support_comment_form) = thread_check_done_message(undef);
	}

	# �L���������擾
	if($in{'No'} ne "0" && $use_thread->{'key'} ne "3"){
		($viewmemo) = thread_get_memo($use_thread);
	}

	# �֘A�X���b�h���擾
	if($concept !~ /NOT-KR/ && !Mebius::Switch::light() ){ # && !Mebius::Switch::thread_light()
		my($edit);
		require "${init_directory}part_kr.pl";
			if($my_use_device->{'wide_flag'}){
				($related_line) = related_thread("Oneline",$moto,$in{'no'},6);
			}
			else{
				($related_line) = related_thread("Oneline",$moto,$in{'no'},2);
			}

		if($related_line){
				if($mytopic_flag || $my_account->{'admin_flag'}){ $edit = qq(�i<a href="$in{'no'}_data.html#KR">���ҏW</a>�j); }
			$related_line = qq(<div class="kr scroll"><div class="scroll-element">�֘A�����N�F $related_line$edit</div></div>);
		}
	}

# �L���薼�G���A
my $zero_res_line .= qq(
$deleted_text
$sexvio_text

<div class="sub_area">
$view_sub<strong>�@( <a href="/_$moto/" class="vtitle" style="color:$use_thread->{'zero_color'};">$head_title</a> ) </strong>

);

	if($my_use_device->{'wide_flag'}){ $zero_res_line .= qq($navi_line\n); }
$zero_res_line .= qq($support_comment_form</div>\n);

# �[���L���̃f�[�^�𕪉�
my @top_line_splited = split(/<>/,$use_thread->{'all_line'}->[1]);

# No.0 �� ���X����
$zero_res_line .= qq(\n);
($zero_res_line) .= thread_res_core({ view_type => "zero" },\@top_line_splited,$use_thread);
$zero_res_line .= qq(\n);
$zero_res_line .= qq($ads_up);

	if(!$my_use_device->{'wide_flag'}){ $zero_res_line .= qq(<div class="lsm" style="padding:1em 0em;margin-top:1em;">$navi_line</div>\n); }

	# �E���L�� ( �f�X�N�g�b�v�� )
	if(!$my_use_device->{'smart_flag'}){

		$zero_res_line = qq(
		<table class="no width100"><tr>
		<td class="no valign-top">$zero_res_line</td>
		<td class="no valign-top thread_ads_right" style="width:180px;">$ads_thread_right</td>
		</tr></table>\n
		);

	}

	# �ᔽ�񍐃����N
	if(!Mebius::BBS::secret_judge() && !Mebius::Admin::admin_mode_judge()){
		$report_line .= qq(<div class="right margin-top">);
		my($move_to_report_mode_button) = shift_jis(Mebius::Report::move_to_report_mode_button({ url_hash => "#a" , ViewResReportButton => $use_thread->{'res'} }));
		$report_line .= qq($move_to_report_mode_button);
		$report_line .= qq(</div>);

	}

	# �[���L�� ( �T�u�L�� )
	if($subtopic_mode){
		($line) = thread_get_subzero($use_thread);

	}

	# �[���L�� ( ���C���L�� )
	else{
			if($my_use_device->{'smart_phone_flag'}){
				$line .= 	$ads_first_view;
			}

		$line .= qq(
		<div class="d" style="color:$use_thread->{'zero_color'};">
		$zero_res_line
		
		<div class="clear">$viewmemo</div>
		$related_line
		$tag_line
		
		$sorcial_line
		$report_line
		</div>
		);
	}


return($line);

}

#-----------------------------------------------------------
# �L���i�r�Q�[�V����
#-----------------------------------------------------------
sub thread_navi_zero{

# �Ǐ���
my($line);
my $use = shift;
my $use_thread = shift;
my $main_thread = shift;
my $sub_thread = shift;
my($my_use_device) = Mebius::my_use_device();
my($my_access) = Mebius::my_access();
my $html = new Mebius::HTML;
my $javascript = new Mebius::Javascript;
my($subres_move,$split_mark,$crap);
our($concept,%in,$sikibetu,$subtopic_link,$moto,$pageview,$sub_nofollow,$count);
my $res = $main_thread->{'res'};
my $key = $main_thread->{'key'};
#my $subkey = $sub_thread->{'key'};
#my $subres = $sub_thread->{'res'};
my $subres = $main_thread->{'sub_thread_res'};
my $bbs_path = Mebius::BBS::Path->new($moto,$in{'no'});

	# �X�}�t�H�U�蕪��
	if($my_use_device->{'smart_flag'}){
		$split_mark = " "; 
	}
	else{
		$split_mark = " - "; 
	}

	# �o�u
	#if(defined($pageview)){ $line .= qq($split_mark<a href="all-pvall.html">�A�N�Z�X(${pageview})</a>); }
	if(defined($pageview)){ $line .= qq(${split_mark}�A�N�Z�X(${pageview})); }

	# �����ˁI�֌W�̏���
	if(!Mebius::BBS::sub_bbs_judge_auto()){
		($count) = Mebius::BBS::get_crap_count($use,$use_thread);
	}

	# ���X���\��
	#if($in{'r'} eq "" && $in{'No'} eq "" && $res >= 1){ $line .= qq($split_mark<a href="#S${res}" class="move">�����X($res)</a>); }

	# ���C���L���̒��ŁA�T�u�L����\������
	if($subtopic_link){

			# SSS �T�u�L���ւ̃����N���Ȃ��X���b�h�̏C�� - 2012/12/14 (��)
			if($subres eq "" && ( $main_thread->{'posttime'} < 1355485142 || Mebius::alocal_judge() ) ){
				my($sub_thread) = Mebius::BBS::thread_state($in{'no'},"sub$moto");
				
					Mebius::BBS::thread({ Renew => 1 , select_renew => { sub_thread_res => $sub_thread->{'res'} } } ,$moto,$in{'no'});
					Mebius::AccessLog(undef,"Sub-thread-link-losted-repair-since-2012_12_14");
					$subres = $sub_thread->{'res'};
			}

			if(!$res){ $res = 0; }
		$line .= qq($split_mark<span class="red">�����C���L��($res) / </span>);
			if(!$subres && $key eq "3"){
				$line .= qq(<span class="green">���T�u�L��(0)</span>);
			}	else {
				my $sub_thread_url = $bbs_path->thread_url_adjusted({ SubThread => 1 });
					if($subres){ 
						$subres_move = qq(<a href="$sub_thread_url#S$subres" class="green"$sub_nofollow>($subres)</a> );
					}
				$line .= qq(<a href="$sub_thread_url" class="green"$sub_nofollow>�T�u�L��</a> $subres_move);
			}
	}

	# �����ˁI�{�^���̕\��
	if($concept !~ /NOT-SUPPORT/ && $main_thread->{'keylevel'} >= 0.5){

			if($my_use_device->{'level'} >= 2) {
				my $move = qq(#a) if $my_use_device->{'narrow_flag'};
				$line .= qq(<form method="post" action="./$in{'no'}.html$move" class="inline" id="bbs_thread_button" $sikibetu>);
				$line .= qq(<div class="inline">);
				$line .= qq(<input type="hidden" name="mode" value="support">);
				$line .= qq(<input type="hidden" name="no" value="$in{'no'}">);
				$line .= qq(<input type="hidden" name="moto" value="$in{'moto'}">);

					if($ENV{'HTTP_COOKIE'}){
						$line .= qq($split_mark);
						$line .= qq(<input type="submit" name="thread_check" value="�X�V�����`�F�b�N" title="�h�ŋ߂̃��X�h�ɕ\\�������悤�ɂȂ�܂�" class="submit_support">);
					}

				my %good_button = ( id => "bbs_thread_good_$use_thread->{'bbs_kind'}_$use_thread->{'number'}" );
		
					if($crap->{'done_flag'} || Mebius::Switch::stop_bbs()){
						$good_button{'disabled'} = 1;
						$good_button{'class'} = "good_disbled";
					} else {
						$good_button{'class'} = "good";
						$good_button{'onclick'} = "push_good({},this,$count,1);return false;";
					}

				$line .= qq($split_mark);
				$line .= $html->input("submit","crap","������($count)",\%good_button);

				$line .= qq(</div>);
				$line .= qq(</form>);
			}
				else{ $line .= qq(${split_mark}�����ˁI($count)); }

		$line .= shift_jis($javascript->push_good("bbs_thread_button"));

	}


	# �c�C�[�g�{�^��
	if(!Mebius::BBS::secret_judge()){
		#my $gaget = new Mebius::Gaget;
		#$line .= qq( - ) . $gaget->tweet_button();
	}


$line = qq(<div class="small inline">$line</div>);

return($line);

}


#-------------------------------------------------
# ���X�����o��
#-------------------------------------------------
sub thread_res_core{

# �錾
my $use = shift if(ref $_[0] eq "HASH");
my $data_line = shift;
my $use_thread = shift;
my $fillter = new Mebius::Fillter;
my($edit,$line,$resnumber,$supple_line,$view_trip,$data_line_array_ref);
my($image_file,$image_server_domain,$image_view,$comment_style,$plus_class,$account_link,$view_id,$view_name,$res_crap,$report_check_box);
my(%res_concept,$p_class,$move_history,$move_to_report_mode_button,$search,$report_check_box);
my($my_use_device) = Mebius::my_use_device();
my($my_real_device) = Mebius::my_real_device();
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
my($server_domain) = Mebius::server_domain();
my($init_bbs) = Mebius::BBS::init_bbs_parmanent_auto();
our($paint_url,$script,$resedit_mode,$realmoto);
my($param) = Mebius::query_single_param();

	# �f�[�^�̎󂯎����@���`
	if(ref $data_line eq "ARRAY"){
		$data_line_array_ref = $data_line;
	} else {
		my(@data_line_not_splited) = split(/<>/,$data_line) ; # ��؂��Ă��Ȃ��P�s�f�[�^�����̂܂ܓn���ꂽ�ꍇ
		$data_line_array_ref = \@data_line_not_splited;
	}

# �f�[�^�𕪉�
my($res_number,$ranum,$nam,$trip,$com,$date,$ho,$id,$color,$mvw,$user,$deleted,$account,$image_data,$res_concept,$regist_time2) = @$data_line_array_ref;

	# ���X�����S�ɏ����ς݂̏ꍇ
	if($res_concept =~ /Vanished/){
		return();
	}

	# �X���b�h������
	if($param->{'word'}){
		($search) = bbs_tsearch($param->{'word'},"high-light","$nam��$trip",$com,$id,$account);
			if(!$search->{'hit'}){ return(); }
			if($search->{'high_lighted_comment'}){ $com = $search->{'high_lighted_comment'}; }
	}

# $res_concept �� �n�b�V����
foreach(split(/\s/,$res_concept)){ $res_concept{$_} = 1; }

# �ړ������N
my $move_history = qq(#subject) if($my_use_device->{'smart_flag'});

	# �R�����g���폜�ς݂��ǂ����𔻒�
	my($comment_deleted_flag) = Mebius::BBS::comment_deleted_judge($use_thread->{'res_data'}->{$res_number});

	# �����X���폜����Ă��Ȃ��ꍇ
	if(!$comment_deleted_flag){

			if( our $candel_mode && $user && $user eq $ENV{'REMOTE_USER'}){

					# �폜�����N
					if($deleted eq ""){ $edit .= qq( ( <a href="$script?mode=resdelete&amp;no=).e($param->{'no'}).qq(&amp;type=delete&amp;res=$res_number">�폜</a> ) ); }
					# ���������N
					elsif($res_number == 0){ $edit .= qq( ( <a href="$script?mode=resdelete&amp;no=).e($param->{'no'}).qq(&amp;type=revive&amp;res=$res_number">����</a> ) ); }
			}

			# �L����ɂ��폜�����N
			elsif(Mebius::BBS::allow_thread_master_delete_judge($use_thread,$use_thread->{'res_data'}->{$res_number},$init_bbs) == 1){
				$edit .= qq( \( <a href="$script?mode=resdelete&amp;no=).e($param->{'no'}).qq(&amp;type=&amp;res=).e($res_number).qq(&amp;do=thread_master">�폜</a> \) );
			}

			# �C�������N
			if($resedit_mode && $my_account->{'key'} eq "1" && $regist_time2){

					if($my_account->{'id'} eq $account && $account && $date){
								if(time < $regist_time2 + ($resedit_mode*60*60)){ # && $key eq "1"
									my $left_hour = int(( ($regist_time2 + ($resedit_mode*60*60) - time)) / (60*60));
									my($left_hour) = Mebius::SplitTime("Not-get-minute Not-get-second",(($regist_time2 + ($resedit_mode*60*60))) - time);
									$edit .= qq( \( <span class="guide">����${left_hour}�ȓ��Ȃ�<a href="$script?mode=resedit&amp;no=).e($param->{'no'}).qq(&amp;res=$res_number#RESFORM">�C��</a>�ł��܂�</span> \)  );
								}
					}
			}

	}

	# �n�C���C�g
	if($use->{'search_keyword'}){
		$com = Mebius::Search::high_light_shift_jis($com,$use->{'search_keyword'});
	}

	# �s���̉��s���폜
	if($my_use_device->{'smart_display_flag'}){
		($com) = Mebius::Text::DeleteHeadSpace(undef,$com);
	}

# �I�[�g�����N
$com = thread_auto_link($com,$param->{'no'},$use_thread->{'res'});

	# �Ǘ��҂̓��e�̏ꍇ (���`��)
	if($mvw eq "<A>") { $res_concept{'Admin-regist'} = 1; }

	if( $res_number ne "0" &&  (my $message = $fillter->each_comment_fillter_on_shift_jis($com) )){
		$com = $message;
	}

	if( my $message = $fillter->each_comment_fillter_on_shift_jis($nam)){
		$nam = $message;
	}

	# �M�����폜����Ă���ꍇ
	if($res_concept{'Deleted-handle'} || $comment_deleted_flag){ $nam = qq(�폜�ς�); $trip = undef; }

	# ID���������N
	if($id){
		$view_id = qq(��$id);
			# ID����
			if($res_concept{'Idory5'} && !$comment_deleted_flag){
				my($devce_encid,$pure_encid,$option_encid) = Mebius::SplitEncid(undef,$id);
				my($id_encoded) = Mebius::Encode("Escape-slash",$pure_encid);
				$view_id = qq(<a href="$basic_init->{'main_url'}history-id-$id_encoded.html$move_history" class="idory">$view_id</a>);
			}
	}

	# ID ���`
	if($view_id){
		if($search->{'id_hit'}){ $view_id = qq( <strong class="hit">$view_id</strong>); }
		elsif($res_concept{'Admin-regist'}){ $view_id = qq( <i style="background:#f00;">$view_id</i>); }
		else{ $view_id = qq( <i>$view_id</i>); }
	}

	if($trip && $res_concept{'Tripory'} && !$comment_deleted_flag){
		my($trip_encoded) = Mebius::Encode("Escape-slash",$trip);
		my($trip_class) = qq( class="hit") if($search->{'name_hit'});
		$view_trip = qq(<span class="trip"><a href="$basic_init->{'main_url'}history-trip-$trip_encoded.html$move_history" class="black">��$trip</a></span>);
	}
	elsif($trip){
		$view_trip = qq(<span class="trip">��$trip</span>)
	}

	# �A�J�E���g
	if($account && !$res_concept{'Hide-account'}){

			# �M���̃����N
			my $class;
				if($search->{'name_hit'}){ $class = qq( class="hit"); }
				else{ $class = qq( class="black"); }

		$view_name = qq(<a href="$basic_init->{'auth_url'}$account/"$class>$nam</a>);

			my $account_href = qq($basic_init->{'auth_url'}$account/);
			my $history_href = qq($basic_init->{'main_url'}history-account-$account.html$move_history);

				if(Mebius::BBS::view_account_history_judge($res_concept)){
					my $account_class;
						if($search->{'account_hit'}){
							$account_class = qq( class="hit");
						} else {
							$account_class = qq( class="ac");
						}
					$account_link .= qq( <a href=") . e($history_href) . qq("$account_class>) . e("\@${account}") . qq(</a>);
					#$account_link .= qq( | <a href=") . esc($account_href) . qq(" class="size90">�v���t�B�[��</a>);
				} else {
						if($search->{'account_hit'}){
							$account_link .= qq( <strong class="hit ac">) . e("\@${account}") . qq(</strong>);
						} else {
							$account_link .= qq(<span class="ac">) . e("\@${account}") . qq(</span>);
						}
				}

	} else {

			# �M���̃����N
			if($search->{'name_hit'}){
				$view_name = qq( <strong class="hit">$nam</strong>);
			} else {
				$view_name = qq($nam);
			}

	}

	# �摜�\�����`
	if($image_data eq "1"){

		#my(%image) = Mebius::Paint::Image("Get-hash Justy",undef,undef,$server_domain,$realmoto,$param->{'no'},$res_number);
			#if($image{'deleted'}){
			#	$image_view .= qq(<div>);
			#	$image_view .= qq(<span class="alert">�摜�͍폜�ς݂ł��B</span>);
			#	$image_view .= qq(</div>);
			#}
			#elsif($image{'image_ok'}){

			my($samnale_url) = Mebius::Paint::samnale_url($realmoto,$use_thread->{'number'},$res_number);
			my($html_url) = Mebius::Paint::html_url($realmoto,$use_thread->{'number'},$res_number);

				$image_view .= qq(<div>);
				$image_view .= qq(<a href="$html_url">);
					#if($cimage_link eq "hide"){ $image_view .= qq(���G�����摜 $image{'title'}); } else{ }
				#$image{'samnale_style'}$image{'title_tag'}
				$image_view .= qq(<img src="$samnale_url" alt="���G�����摜" class="paint_image">);
				$image_view .= qq(</a>);
				#if($image{'data'}){ $image_view .= qq(<div style="color:#555;font-size:90%;">$image{'data'}</div>); }
				#if($image{'key'} =~ /Animation/){ $image_view .= qq(<br$main::xclose>[ <a href="$image{'html_url'}">�A�j���[�V����</a> ]); }
				$image_view .= qq(</div>);
			#}
	}

	# �t�H���g�̕ύX
	my($comment_style) = Mebius::BBS::CommentStyle(undef,$res_concept);

	# �[���L���̏ꍇ
	if($use->{'view_type'} ne "zero"){ $line .= qq(<div class="d$plus_class" style="color:$color;" id="S${res_number}">); }


	# �������݊��� ���m�点����
	my($seal) = shift_jis_return(Mebius::BBS::Posted::last_regist_seal($use_thread->{'bbs_kind'},$use_thread->{'number'},$res_number));
	$line .= $seal;


	# �x���˔j
	if($resnumber ne "0" && $res_concept =~ /Alert-break(-)?(\[(.+?)\])?/ && !$comment_deleted_flag){
		$supple_line .= qq(<div class="supple_res">���x���ɓ��ӂ��ď������܂�܂���);
			if($3){ $supple_line .= qq( \($3\)); }
		$supple_line .= qq(</div>\n);
	}

	# �폜�ς݂̏ꍇ
	if($comment_deleted_flag){
		$p_class = qq( class="deleted_comment");
	}

# ���폜�˗��̃`�F�b�N�{�b�N�X


	if($res_number ne "0" && Mebius::Report::report_mode_judge_for_res() && !$param->{'single_reason_report_mode'}){
		($report_check_box) = shift_jis(Mebius::Report::report_check_box_per_res({ content_type => "bbs_thread" , handle_deleted_flag => $res_concept{'Deleted-handle'} , comment_deleted_flag => $comment_deleted_flag },"bbs_thread_$use_thread->{'bbs_kind'}_$use_thread->{'number'}_$res_number"));
	}

	# ���폜�˗��{�^����Javascript�ŏ����o��
	if($res_number ne "0" && !Mebius::Report::report_mode_judge() && !$use->{'ViewReport'} && !Mebius::Switch::stop_user_report()){

			# �R�����g���M�����폜�ς݂̏ꍇ�́A�񍐃{�^��������
			if($res_concept{'Deleted-handle'} && $comment_deleted_flag){
				$move_to_report_mode_button .= qq(<script>rrb\(\);</script>); 
			} else {
				$move_to_report_mode_button .= qq(<script>rrb\().e($res_number).qq(\);</script>);
			}

		my $javascript = qq(
		document.write\('
			�@
			<form action="./?report#REPORT_RES" class="inline" method="POST">
			<input type="hidden" name="single_reason_report_mode" value="1">
			<input type="hidden" name="moto" value=").e($param->{'moto'}).qq(">
			<input type="hidden" name="mode" value=").e($param->{'mode'}).qq(">
			<input type="hidden" name="no" value=").e($param->{'no'}).qq(">
		'\);

		document.write\('
			<input type="hidden" name="report_res" value="'+res_number+'">
			<input type="hidden" name="No" value="'+res_number+'">
		'\);

			if(res_number){
				document.write\('<input type="submit" name="report_mode_for_res" value="��" class="white">'\);
			} else {
				document.write\('<input type="button" value="��" class="white disabled" disabled>'\);
			}
		document.write\('</form>'\);
		);

		$javascript =~ s/[\n\r\t]//g;

		$main::javascript_text = qq(
		function rrb(res_number){
			$javascript;
		}
		);
		
	}

	# ���\���������ŏI��`
	{

		my($right_side_area);



		# �M���Ɩ{��
		#$right_side_area .= qq(<p class="name"><b>$res_number $view_name</b>$account_link$view_trip$view_id$edit</p><p$comment_style$p_class>$com</p>$image_view);
		$right_side_area .= qq(<p class="name"><b> $view_name</b>$account_link$view_trip$view_id$edit</p><p$comment_style$p_class>$com</p>$image_view);

		$right_side_area .= qq($supple_line);

		# ���t����
		$right_side_area .= qq(<div class="date blk">);

			if($regist_time2 && !defined $use->{'absolute_date_flag'}){
				# ���X�Ԃ������N����ꍇ
				my $res_number_link = qq(./$use_thread->{'number'}.html-$res_number#a)
							if($param->{'No'} ne $res_number);	#!$my_use_device->{'bot_flag'} && 
				my($howlong) = shift_jis(Mebius::second_to_howlong({ TopUnit => 1 , HowBefore => 1 , ColorView => 1 , link => $res_number_link  } , time -  $regist_time2)); # , link_nofollow_flag => 1
				$right_side_area .= q(<span title=").e($date).q(">).$howlong.q(</span>);
			} else {
				$right_side_area .= e($date);
			}

			#if($res_number){
			#	$right_side_area .= qq(�@);
			#	$right_side_area .= qq(No.$res_number);
			#}
		$right_side_area .= q( No.).e($res_number);

			# �X�}�t�H
			if($my_use_device->{'smart_flag'}){
				# <a href="#a" class="move">���ŏ�</a>
				$right_side_area .= qq( <a href="#c" class="move">���ԐM</a>);
			}
		$right_side_area .= qq($move_to_report_mode_button);
		$right_side_area .= qq(</div>);
		$right_side_area .= qq($report_check_box);

		$line .= $right_side_area;
	}

	# ����
	if($use->{'view_type'} ne "zero"){ $line .= qq(</div>); }

return($line);

}


#-------------------------------------------------
# �L�������̕\�����e���`
#-------------------------------------------------
sub thread_get_memo {

my $use_thread = shift;
my $memo_body = $use_thread->{'memo_body'};
my $memo_editor = $use_thread->{'memo_editor'};
my($my_use_device) = Mebius::my_use_device();
my($basic_init) = Mebius::basic_init();
my($pri_memo_body,$pri_memo_body_hidden,$i,$line,$memo_pri_max,$flow_flag,$hidden_count);
my($param) = Mebius::query_single_param();
my $fillter = new Mebius::Fillter;
our(%in);

	# �ݒ�
	if($my_use_device->{'narrow_flag'}){
		$memo_pri_max = 3;
		$memo_body =~ s/(<br>){2,}/<br>/g;
	}
	else{
		$memo_pri_max = 30;
		$memo_body =~ s/(<br>){3,}/<br><br>/g;
	}



$line .= qq(<div class="tmemo" id="MEMO">);

	# �L�������̓��e��W�J
	if($memo_body ne ""){

			foreach(split(/<br>/,$memo_body)){

				my $comment = $_;

				$i++;

					# �R�����g�A�E�g
					if($_ =~ /^\/\//){ next; }

					if($comment eq ""){ $comment = "<br>"; }

					if($i > $memo_pri_max){
						$pri_memo_body_hidden .= qq(<p>$comment);
						$flow_flag = 1;
						$hidden_count++;
					}
					else{
						$pri_memo_body .= qq(<p>$comment);
					}
	}

	if( my $message = $fillter->each_comment_fillter_on_shift_jis($pri_memo_body) ){
		$pri_memo_body = $message;
	}

	($pri_memo_body) = thread_auto_link($pri_memo_body,$param->{'no'},$use_thread->{'res'});
	($pri_memo_body_hidden) = thread_auto_link($pri_memo_body_hidden,$param->{'no'},$use_thread->{'res'});

# �ҏW���𕪉�
my($memo_name,$memo_id,$memo_trip,$memo_time,$memo_addr,$memo_host,$memo_number,$memo_account,$memo_date) = split(/=/,$memo_editor);
if($memo_trip){ $memo_name = "$memo_name��$memo_trip"; }

	# ccc
	if($memo_id =~ /^(SOFTBANK|AU|DOCOMO|MOBILE|PSP)$/){ }

	elsif($memo_account){ $memo_name = qq($memo_name <a href="$basic_init->{'auth_url'}$memo_account/">\@$memo_account</a>); }

		$line .= qq(<a href="$in{'no'}_memo.html" rel="nofollow">����</a>	�i <b>$memo_date �F $memo_name</b><i>��$memo_id</i> �j);
		$line .= qq(<div>);
		$line .= qq($pri_memo_body);

			if($flow_flag){
				$line .= qq(<p><a href="javascript:vblock('memo_hidden');vnone('memo_open')" class="fold" id="memo_open">�c������ǂ�(${hidden_count}�s)</a>);
				$line .= qq( <div class="display-none" id="memo_hidden">$pri_memo_body_hidden);
				$line .= qq(<p><a href="#MEMO" onclick="vinline('memo_open');vnone('memo_hidden');" class="fold" id="memo_close">�~����</a></div>);
			}
		$line .= qq(</div>);

	}
	else{
		$line .= qq(<a href="$in{'no'}_memo.html" rel="nofollow">�c���̋L���Ƀ���������</a>);
	}


$line .= qq(</div>);

return($line);

}


#-------------------------------------------------
# �����N����
#-------------------------------------------------
sub thread_auto_link {

# �錾
my($msg,$thread_number,$thread_res_num) = @_;

	# �e�L�X�g����
	($msg) = Mebius::Effect::all($msg);

# http:// �`���̃����N
($msg) = Mebius::auto_link($msg);

# ���X�ԃ����N
$msg =~ s/No\.([0-9,\-]+)/thread_auto_link_core($thread_number,$thread_res_num,$1);/eg;


return($msg);

}

#-----------------------------------------------------------
# �����N �R�A����
#-----------------------------------------------------------

sub thread_auto_link_core{

my($thread_number,$thread_res_num,$res_anthor) = @_;
my($self,$auto_link_flag);

	# �P�����N
	if($res_anthor =~ /^([0-9]+)$/){
			if($1 <= $thread_res_num){
				$auto_link_flag = 1;
			}

	# �͈͎w�胊���N
	} elsif($res_anthor =~ /^([0-9]+)-([0-9]+)$/){
			if($1 <= $thread_res_num || $2 <= $thread_res_num){
				$auto_link_flag = 1;
			}

	# �ʎw�胊���N
	} elsif($res_anthor =~ /^([0-9]+[0-9,]+)$/){

		# �w��ȓ��̃��X�Ԃ��ЂƂł������	
		foreach(split /,/,$1 ){
				if($_ <= $thread_res_num){
					$auto_link_flag = 1;
				}
		}

	# �ǂ�ł��Ȃ��ꍇ
	} else {
		0;
	}

	if($auto_link_flag){
		$self = qq(<a href=").e("$thread_number.html-$res_anthor#RES").q(">&gt;&gt;).e($res_anthor).q(</a>);
	} else {
		$self = qq(&gt;&gt;).e($res_anthor);
	}

$self;

}



#-------------------------------------------------
# �X���b�h�����t�H�[�� / �y�[�W�ړ������N / ���X�ԃt�H�[��
#-------------------------------------------------
sub get_tsearch{

my($adtype,$type,$use_thread,$main_thread) = @_;
my($my_use_device) = Mebius::my_use_device();
my($id,$name,$checkarea,$i_page_reverse,$line,$resjump_form,$ads,$round);
my($plus_class,$move1,$sublink,$form_move,$i_page,$subres_move,$id_page_rounder);
my $res = $use_thread->{'res'};
my($parts) = Mebius::Parts::HTML();
our(%in,$moto,$realmoto,$p_page,$pfirst_page,$sub_nofollow,$script,$subtopic_mode,$subtopic_link,$ads_link_md);
my $bbs_path = Mebius::BBS::Path->new($use_thread->{'bbs_kind'},$use_thread->{'thread_number'});
my $html = Mebius::HTML->new();
my $thread_url = $bbs_path->thread_url_adjusted();

# �J�e�S���ݒ���擾
my($init_bbs) = Mebius::BBS::init_bbs_parmanent($moto);

$i_page_reverse = int( ( $res + $pfirst_page -1 ) / $p_page ) -1;

	# �ߏ�ȃ��[�v���֎~ ( �폜���Ȃ� )
	if($i_page_reverse > 1000){
		Mebius::send_email({ ToMaster => 1 },undef,"�f���̋L���ŁA�y�[�W�̃��E���h���� $i_page_reverse �������܂����B $init_bbs->{'title'} ","$use_thread->{'url'}");
		die("Perl Die! Thread res_num and Page round count is very many . is '$i_page_reverse' round .");
	}

	# �P��ڂƓ��ڂ�U�蕪��
	if($type eq "up"){ $ads = $ads_link_md; $id = qq( id="UM"); $name = qq( name="UM"); $round = 1; $id_page_rounder = "UPG"; }
	elsif($type eq "dw"){ $id = qq( id="DM"); $round = 2; $id_page_rounder = "DPG"; }

	# �L�����Ȃ����ꍇ
	if(!$adtype){ $ads = ""; }

	# �X�}�t�H��
	if($my_use_device->{'smart_flag'}){
		$plus_class .= qq( bgkcolor);
	}


$line .= qq(
<div class="p_page bbs_border$plus_class" id="$id_page_rounder">
<div class="inline page_rounder">
<div class="scroll">
<div class="scroll-element">
);

	# ���X������΁A�y�[�W�����N�ꗗ��\�� 
	if($subtopic_link && !$subtopic_mode ){

			if($type eq "dw"){ $move1 = "#UM"; } else{ $move1 = "#UM"; }
			if($main_thread->{'sub_thread_res'} >= 1){
				my $sub_thread_url = $bbs_path->thread_url_adjusted({ SubThread => 1 });
				$subres_move = qq(<a href="$sub_thread_url#S$main_thread->{'sub_thread_res'}" class="green"$sub_nofollow>($main_thread->{'sub_thread_res'})</a> ) if($main_thread->{'sub_thread_res'});
				$line .= qq(<span class="comoji">�ؑցF <span class="red">���C���L��($res)</span> <a href="$sub_thread_url" class="green"$sub_nofollow>�T�u�L��</a> $subres_move</span> �b );
			}
	}

	if($subtopic_mode){ $line .= our $move_mainres; }

	if(!$in{'r'} && !exists $in{'word'}){
		$line .= qq(<span class="comoji">�y�[�W�F <strong class="red">1</strong></span>\n);
	}	else {
		$line .= qq(<span class="comoji">�y�[�W�F );
		$line .= qq(<a href="$thread_url#UPG">1</a>);
		$line .= qq(</span>\n);
	}


	for($i_page = 2 ; $i_page_reverse >= 0 ; $i_page ++ ){

	#	$i_page++; # �t���Ńy�[�W����\������ꍇ�� $i_page_reverse ���g��
		my $nozo = ($i_page_reverse * $p_page)+1;

			if($in{'r'} == $nozo){ $line .= qq(<strong class="red">$i_page</strong>\n); }
			else{
				my $thread_r_url = $bbs_path->thread_usefull_url_adjusted({ r => $nozo });
				$line .= qq(<a href="$thread_r_url#UPG">$i_page</a>\n);
			}

		$i_page_reverse--;
			if($i_page >= 1000){ last; } # ���̂ɂ��ߏ�ȏ�����h��

	}

$line .= qq(</div>);
$line .= qq(</div>);

	# ���X��S�ĕ\�������邽�߂̃����N
	#if($use_thread->{'res'} > $pfirst_page){
	#		if($in{'r'} eq "all"){
	#			$line .= q(�S�ĕ\\��).qq(\n);
	#		} else {
	#			my $thread_all_url = $bbs_path->thread_usefull_url_adjusted({ r => 'all' });
	#			$line .= q(<a href=").e($thread_all_url).qq(#UPG">�S�ĕ\\��</a>).qq(\n);
	#		}
	#}


$line .= $ads;

	# �����ς݂̏ꍇ
	if(exists $in{'word'}){
		($checkarea) = tsearch_get_vfcheckarea("",$round);
	}

	# ���X�ԃt�H�[�����Z�b�g
	if(!$my_use_device->{'smart_flag'}){
		($resjump_form) = res_jump_form(undef,$round);
	}

	# ���\���̍ŏI��`
	{
		my $submit_value;

			# �X�}�t�H��
			if($my_use_device->{'smart_flag'}){
				$form_move = "#RES";				
			} else {
				$form_move = "#UPG";
			}

			if($my_use_device->{'wide_flag'}){ $submit_value = "�X���b�h������"; }
			else{ $submit_value = "�X���b�h������"; }

		$line .= qq(<hr>);
		$line .= qq(<form action="$script$form_move" class="inline"$name$id>);
		$line .= qq(<input type="hidden" name="mode" value="view">);
		$line .= qq(<input type="hidden" name="no" value="$in{'no'}">);
		$line .= qq(<input type="$main::parts{'input_type_search'}" name="word" value="$in{'word'}" placeholder="�����L�[���[�h" class="tsearch" size="10" id="tsearch$round">);
		$line .= qq( <input type="submit" value="$submit_value">);
		$line .= qq($checkarea);
		$line .= qq(</form>);

		# �����N�ꗗ�I��
		$line .= qq(</div>$resjump_form</div>);

	}

return($line);

}


#-----------------------------------------------------------
# ���X�ԃt�H�[��
#-----------------------------------------------------------
sub res_jump_form{

my($line);
my($type,$round) = @_;
our(%in,$realmoto);

$line = qq(�@<form action="./" class="inline" method="post">
<div class="inline">�@
<input type="text" name="No" value="" placeholder="��\) 1" style="width:3em;">
<input type="submit" value="�Ԃ̃��X��\\��">
<input type="hidden" name="mode" value="Nojump">
<input type="hidden" name="moto" value="$realmoto">
<input type="hidden" name="no" value="$in{'no'}">
</div>
</form>);

return($line);

}



#-----------------------------------------------------------
# ����̃��X�Ԃ�\������ۂ̃����N
#-----------------------------------------------------------
sub thread_resaround_links{

# �Ǐ���
my $use_thread = shift;
my($line,$backurl_query_enc_admin);
my($my_use_device) = Mebius::my_use_device();
our(%in,$No_start,$No_end,$script,$title,$reshit_flag);
my $sub = $use_thread->{'sub'};
my $res = $use_thread->{'res'};

	# �L���������̏ꍇ
	if(exists $in{'word'}){
		$line .= qq(<div class="d_ryaku"><span class="ryaku"><strong class="red">�h$in{'word'}�h</strong> �̌������ʁF $reshit_flag�� - <a href="$in{'no'}.html">$sub</a> ( <a href="$script" class="green">$title</a> ));
		$line .= qq(</span></div>);
		return($line);
	}

# ���X�����F��
my($round_num,$first_resnumber) = Mebius::Page::NowPagenumber("Split-resnumber Desktop-view",$in{'No'},$res);

# �\�����e
$line .= qq(<div class="d_ryaku"><span class="ryaku">);

	if($my_use_device->{'wide_flag'}){
		$line .= qq(<a href="$in{'no'}.html">$use_thread->{'subject'}</a> �� <strong class="red">No.$in{'No'}</strong> ������\\�����Ă��܂��B);
	}

my $bot_view_flag = 1;

	if(!$main::bot_access || !$bot_view_flag){

			# ���̃��X
			if($res <= $No_end){ $line .= qq(�����̃��X ); }
			else{ $line .= qq(<a href="$in{'no'}.html-) . ($No_end+1) . qq(#RES" rel="nofollow">�����̃��X</a> ); }

		$line .= qq(<a href="$in{'no'}${round_num}.html#S$first_resnumber">����̃��X</a> );

			# �O�̃��X
			if($No_start <= 0){ $line .= qq(���O�̃��X ); }
			else{ $line .= qq(<a href="$in{'no'}.html-) . ($No_start-1) . qq(#RES" rel="nofollow">���O�̃��X</a> ); }
	}


$line .= qq(</span></div>);

return($line);

}



#-----------------------------------------------------------
# ���X�Ԕ���
#-----------------------------------------------------------
sub thread_check_resnumber{

# �Ǐ���
my($res) = @_;
my($hit);
my($param) = Mebius::query_single_param();
my($No_start,$No_end,$res_comma);
our($p_page);

	# ���݂̂t�q�k�A�y�[�W���Ȃǔ���
	if(exists $param->{'No'}){ $hit++; }
	if(exists $param->{'r'}){ $hit++; }
	if(exists $param->{'word'}){ $hit++; }
	if($hit >= 2){ &error("���[�h�͈�܂ł����I�ׂ܂���B"); }
	if($param->{'r'} eq "all"){ }
	elsif($param->{'r'} ne "" && ($param->{'r'} =~ /([^0-9])/ || $param->{'r'} <= 0 || $param->{'r'} > $res) ){ &error("�y�[�W���̎w�肪�ςł��B"); }



	# ���X�Ԕ���
	if($param->{'No'} eq ""){ return; }

	# �e��G���[
	if($param->{'No'} !~ /\w/){ &error("���X�Ԃ̎w�肪�ςł��B���p���� ( 0-9 ) ��K������Ă��������B "); }
	if($param->{'No'} =~ /[^0-9\-,]/){ &error("���X�Ԃ̎w�肪�ςł��B���p���� ( 0-9 ) �A ���p�J���} ( , ) �A ���p�n�C�t�� ( - ) �����Ŏw�肵�Ă��������B "); }
	if($param->{'No'} =~ /\-/ && $param->{'No'} =~ /\,/){ &error("���X�Ԃ̎w�肪�ςł��B���p�J���} ( , ) �� ���p�n�C�t�� ( - ) �͈ꏏ�Ɏg���܂���B"); }
	if(($param->{'No'} =~ s/\-/$&/g) >= 2){ &error("���X�Ԃ̎w�肪�ςł��B���p�n�C�t�� ( - ) �͂P���������g���܂���B"); }

	# ���C���w��
	if($param->{'No'} =~ /-/) {
		($No_start,$No_end) = split(/-/, $param->{'No'}, 2);
		if($No_start eq "" || $No_end eq ""){ &error("���X�Ԃ̓n�C�t���ŋ�؂��Đ��������͂��Ă��������B"); }
		if($No_start > $No_end){ ($No_start,$No_end) = ($No_end,$No_start); }
		if($No_end - $No_start > $p_page){ $No_end = $No_start + $p_page -1; }
		#$bou = 1;
	}

	# �J���}�w��
	elsif($param->{'No'} =~ /,/){
		$res_comma = 1;
		$No_start = $res;
			foreach ( split(/,/, $param->{'No'}) ) {
					if($_ > $No_end){ $No_end = $_; }
					if($_ < $No_start){ $No_start = $_; }
			}
	}

	# �P��w��
	elsif($param->{'No'} || $param->{'No'} eq "0"){
		$No_start = $No_end = $param->{'No'};
		#$ou = 1;
				#if($param->{'No'} eq "0"){ $No_nores=1; }
	}

	# ���X�w�肪�傫������ꍇ
	if($No_end > $res){ $No_end = $res; }

	# �O�͍ŏ��ɏ����Ȃ�
	if($No_start =~ /^0([0-9+])/ || $No_end =~ /^0([0-9+])/){ &error("���X�Ԃ̎w�肪�ςł��B�ŏ��� 0 �͏����܂���B"); }

$No_start,$No_end,$res_comma;

}


#-----------------------------------------------------------
# �^�C�g����`
#-----------------------------------------------------------
sub thread_set_title{

# �錾
my $use = shift if(@_ >= 2);
my $main_thread = shift;
my(@BCL);
our($realmoto,$p_page,%in,$kfirst_page,$sub_title,$head_title,$kpage,$r_page,$settitle_flag,$head_link);
my $key = $main_thread->{'key'};
my $res = $main_thread->{'res'};
my $sub = $main_thread->{'sub'};
my($server_domain) = Mebius::server_domain();

	if($use->{'SubThread'}){
		$sub = "$sub [�T�u]";
	}

	if($settitle_flag){ return; }

	# �폜�ς݂̎�
	if($key == 4){
		$sub_title = "�폜�ς݋L�� | $head_title";
		push @BCL , "�폜�ς݋L��";
	}
	# �e�L���������̃^�C�g��
	elsif(exists $in{'word'}){
		$sub_title = "�h$in{'word'}�h - $sub | $head_title";
		push @BCL , { url => "$in{'no'}.html" , title => $sub };
		push @BCL , "�h$in{'word'}�h�Ō���";
		my($encword) = Mebius::Encode("",$in{'word'});
	}

	# �`�y�[�W�ڂ̏ꍇ
	elsif($in{'r'} ne ""){

		# �L���ւ̃����N
		push @BCL , { url => "$in{'no'}.html" , title => $sub };

			# �S���X��\��
			if($in{'r'} eq "all"){
				push @BCL , "�S�ĕ\\��";
				$sub_title ="${sub} | $head_title | �S�ĕ\\��"; #  
			}

			# �y�[�W�����\��
			else{

				# �g�єłւ̃��_�C���N�g
				my $mobile_page = ($in{'r'} - 1) - ( ($in{'r'} - 1) % $kpage ) + 1;

				$r_page = int($in{'r'} / $p_page);
				$sub_title ="�y�[�W$r_page | ${sub} | $head_title";
				push @BCL , "$r_page�y�[�W";
			}

	}

	# �i���o�[�����N�̏ꍇ
	elsif($in{'No'} ne ""){
		$sub_title = "$in{'No'} | ${sub} | $head_title";
		push @BCL ,  { url => "$in{'no'}.html" , title => $sub } ;
		push @BCL , "No.$in{'No'}";
	}

	# ���ʂ̏ꍇ
	else{
		$sub_title = "${sub} | $head_title";
		push @BCL , "$sub";
	}



$settitle_flag = 1;

\@BCL;

}



#-------------------------------------------------
# �L���̑I��
#-------------------------------------------------

sub thread_ads_set{

# �錾
my($basic_init) = Mebius::basic_init();
my($my_use_device) = Mebius::my_use_device();
my($type,$tkey) = @_;
my($param) = Mebius::query_single_param();
our($ads_up,$ads_dw,$ads_thread_right,$ads_dw_smart,$ads_first_view,$ads_link_md);

	if(Mebius::Admin::admin_mode_judge()){ return();	}
	if(Mebius::Report::report_mode_judge()){ return(); }

	# ���S�L���Ȃ����[�h�̏ꍇ
	if( our $noads_mode){

		my $ads = new Mebius::Ads;
		$ads_up = qq(<div class="ads_up">).$ads->rakuten_basic_widget().qq(</div>);
		$ads_thread_right = $ads->amazon_vertical_widget();;
		$ads_first_view = $ads->rakuten_smart_phone_widget();
		return();
	}

	# ���e���[�h�̏ꍇ
	if($param->{'mode'} eq "regist" && $ENV{'REQUEST_METHOD'} eq "POST"){ return(); }

	# ���[�J���L��
	if(Mebius::alocal_judge()){

		$ads_thread_right = qq(<div style="width:160px;height:600px;border:solid 1px #000;">�L��</div>);
		$ads_up = qq(<div class="ads_up"><div style="width:300px;height:250px;border:solid 1px #000;">�L��</div></div>);
			if($my_use_device->{'smart_flag'}){
				$ads_dw_smart = qq(<div class="thread_ads_bottom"><div style="width:320px;height:50px;border:solid 1px #000;margin:auto;">�L��</div></div>);
				$ads_first_view = qq(<div class="thread_ads_bottom"><div style="width:320px;height:50px;border:solid 1px #000;margin:auto;">�L��</div></div>);
			}
		#$ads_thread_right = qq(<!-- Rakuten Widget FROM HERE --><script type="text/javascript">rakuten_design="slide";rakuten_affiliateId="1186506d.de78e630.1186506e.6d663e1e";rakuten_items="ctsmatch";rakuten_genreId=0;rakuten_size="148x600";rakuten_target="_blank";rakuten_theme="gray";rakuten_border="off";rakuten_auto_mode="off";rakuten_genre_title="off";rakuten_recommend="on";</script><script type="text/javascript" src="http://xml.affiliate.rakuten.co.jp/widget/js/rakuten_widget.js"></script><!-- Rakuten Widget TO HERE -->);

		return();
	}


# �����N���j�b�g
$ads_link_md = '<hr>
<script type="text/javascript"><!--
google_ad_client = "ca-pub-7808967024392082";
/* �����N���j�b�g���� */
google_ad_slot = "6688913329";
google_ad_width = 728;
google_ad_height = 15;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
';



	# ��PC�� - �n��n - �e�L�X�g�L���̂�
	if($main::bbs{'concept'} =~ /Sousaku-mode/){ # && our $category ne "diary"


		$ads_up = '
			<div class="ads_up">
			<script type="text/javascript"><!--
			google_ad_client = "ca-pub-7808967024392082";
			/* �L���㕔 �e�L�X�g */
			google_ad_slot = "2763636528";
			google_ad_width = 300;
			google_ad_height = 250;
			//-->
			</script>
			<script type="text/javascript"
			src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
			</script>
			</div>
		';

		$ads_thread_right = '
		<script type="text/javascript"><!--
		google_ad_client = "ca-pub-7808967024392082";
		/* �L���E�� �e�L�X�g�̂� */
		google_ad_slot = "8608033727";
		google_ad_width = 160;
		google_ad_height = 600;
		//-->
		</script>
		<script type="text/javascript"
		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
		';

	# ��PC�� - �J�e�S���n�Ȃ�
	} else {

		# �y�[�W�㕔�̍L��
		$ads_up = '
			<div class="ads_up">
			<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
			<!-- �L���㕔�P�� -->
			<ins class="adsbygoogle"
			     style="display:inline-block;width:336px;height:280px"
			     data-ad-client="ca-pub-7808967024392082"
			     data-ad-slot="0295167174"></ins>
			<script>
			(adsbygoogle = window.adsbygoogle || []).push({});
			</script>
			</div>
		';

		# �r�b�O�o�i�[
		$ads_dw = q(
		<div class="thread_ads_bottom">
		<script type="text/javascript"><!--
		google_ad_client = "ca-pub-7808967024392082";
		/* �L�����r�b�O�o�i�[ */
		google_ad_slot = "6783708511";
		google_ad_width = 728;
		google_ad_height = 90;
		//-->
		</script>
		<script type="text/javascript"
		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
		</div>
		);


		# �L���E��
		$ads_thread_right = q(
		<script type="text/javascript"><!--
		google_ad_client = "ca-pub-7808967024392082";
		/* �L���E�� */
		google_ad_slot = "7336775483";
		google_ad_width = 160;
		google_ad_height = 600;
		//-->
		</script>
		<script type="text/javascript"
		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
		);


	}




	# �X�}�t�H�L��
	if($my_use_device->{'smart_ad_flag'}){

			# �n��n
			if($main::bbs{'concept'} =~ /Sousaku-mode/){
				$ads_first_view = q(
				<div class="ads_first_view center">
				<script type="text/javascript"><!--
				google_ad_client = "ca-pub-7808967024392082";
				/* �X�}�t�H�o�i�[ �e�L�X�g�̂� */
				google_ad_slot = "1084766928";
				google_ad_width = 320;
				google_ad_height = 50;
				//-->
				</script>
				<script type="text/javascript"
				src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
				</script>
				</div>	
				);

			# �b�n
			} else {

				$ads_first_view = q(
				<div class="ads_first_view center">
				<script type="text/javascript"><!--
				google_ad_client = "ca-pub-7808967024392082";
				/* �X�}�t�H�o�i�[ */
				google_ad_slot = "1226476247";
				google_ad_width = 320;
				google_ad_height = 50;
				//-->
				</script>
				<script type="text/javascript"
				src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
				</script>
				</div>
				);

			}

		$ads_up = q(
		<div class="ads_up center">
		<script type="text/javascript"><!--
		google_ad_client = "ca-pub-7808967024392082";
		/* �L���㕔�@�X�}�t�H */
		google_ad_slot = "3357778833";
		google_ad_width = 300;
		google_ad_height = 250;
		//-->
		</script>
		<script type="text/javascript"
		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
		</div>
		);

		$ads_dw_smart = q(
		<div class="thread_ads_bottom center">
		<script type="text/javascript"><!--
		google_ad_client = "ca-pub-7808967024392082";
		/* �L���� �X�}�t�H */
		google_ad_slot = "7405420205";
		google_ad_width = 320;
		google_ad_height = 50;
		//-->
		</script>
		<script type="text/javascript"
		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
		</div>
		);

		$ads_link_md = $ads_thread_right = $ads_dw ='' ;

			# �����ɂ̓X�}�t�H�L����\�����Ȃ��i��N���b�N�h�~�j
			if($basic_init->{'master_addr_flag'} && $my_use_device->{'type'} eq "Smart-phone"){
				$ads_up = qq(<div class="ads_up"><div style="width:250px;height:250px;border:solid 1px #000;margin:auto;">�L��</div></div>);
				$ads_dw_smart = qq(<div class="thread_ads_bottom"><div style="width:320px;height:50px;border:solid 1px #000;margin:auto;">�L��</div></div>);
			}

	}

Mebius::delete_tab($ads_up,$ads_dw,$ads_thread_right,$ads_dw_smart,$ads_first_view);

}

1;
