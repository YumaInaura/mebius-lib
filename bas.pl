
use Mebius::BBS;
use Mebius::Page;

package main;
use strict;

#-------------------------------------------------
#  ��{���� - strict
#-------------------------------------------------
sub init_start_bbs{

# �錾
my($basic_init) = &Mebius::BasicInit();
my($init_directory) = &Mebius::BaseInitDirectory();
my($server_domain) = &Mebius::ServerDomain();
my($type) = @_;
my($eval,$original_moto);
our(@color,$menu1,$menu2,$p_page,$pfirst_page,$kfirst_page,$m_max,$i_max,$kpage,$new_wait);
our($upload_url,$upload_dir,$realmoto,$moto,$logdir,$category,$nowfile,$pastfile,$home,$hometitle,$concept);
our($backup_dir,$alocal_mode,$secret_mode,$bbs_redirect,%in);

# �����F
(@color) = &Mebius::Init::Color();

# �e��ݒ�
$menu1 = 30;		# ���s���O�A�P���j���[������̍ő�L���\����
$menu2 = 100;		# �ߋ����O�A�P���j���[������̍ő�L���\����
$i_max = 300;		# �f���P������́A�ő�L����
($p_page,$pfirst_page) = &Mebius::Page::InitPageNumber("Desktop-view"); # �y�[�W�����ݒ���擾
($kpage,$kfirst_page) = &Mebius::Page::InitPageNumber("Mobile-view"); # �y�[�W�����ݒ���擾
$m_max = 2000;		# �L���P������́A�ő僌�X�o�^��
$new_wait = 72;		# �V�K���e�̑҂����ԁi�`���ԁj

# ���e�̊�{�ݒ�
our $wait = 4;				# ���X�̊�{�҂�����
our $max_msg = 6000;		# ���X�̍ő啶����
our $min_msg = 10;			# ���X�̍ŏ�������
our $new_max_msg = 9000;	# �V�K���e�̍ő啶����
our $new_min_msg = 100;		# �V�K���e�̍ŏ�������
our $ngbr = 300;			# ���e���̍ő���s��

	# ���[�J���ݒ� (���݂͕s�g�p?)
	#if(&Mebius::AlocalJudge() && !$main::admin_mode){
	#	$backup_dir = "./_backup_home/";
	#}

# $moto���`
$original_moto = $moto;
	if($type =~ /Admin-mode/){}
	elsif($realmoto =~ /^sc([a-z0-9]+)$/){ } # �閧��
	else{
		$moto = $in{'moto'};
			if($moto =~ /[^0-9a-z]/){ &error("�f���̎w�肪�ςł��B"); }
		$realmoto = $moto;
		$moto =~ s/^sub//;
			if($moto eq ""){ &error("�f�����w�肵�Ă��������B"); }
	}

# �V�ݒ�t�@�C��(�ʐݒ�)��ǂݍ���
our(%bbs) = &main::InitBBS("Get-global Get-hash",$moto);

	# �f�����ݒ肳��Ă��Ȃ��ꍇ
	if(!$bbs{'alive'}){
			# BBS.pm �̒��ɔz�񂪂���ꍇ�́A�f���������쐬
			if($main::myaccount{'admin_flag'}){
				my(%all_bbs_hash) = &Mebius::BBS::BBSNameAray("Get-all-category");
					if($all_bbs_hash{$moto}){
						&Mebius::Fileout("Allow-empty Deny-f-file-return",$bbs{'file'});
						&Mebius::Mkdir(undef,$bbs{'data_directory'});
					}
					else{ &main::error("���̌f���͐ݒ肳��Ă��܂���B"); }
			}
			# �ݒ肳��Ă��Ȃ��f���̃G���[���o��
			else{ &main::error("���̌f���͐ݒ肳��Ă��܂���B"); }
	}

	# �����̌f����
	if($concept =~ /Admin-only/ && $type !~ /Admin-mode/){ &main::error("���̌f���͐ݒ肳��Ă��܂���B"); }
	if($concept =~ /BBS-CLOSE/){ &main::error("���̌f���͕����ł��B","410 Gone"); }

	# ���O�C�����[�h
	if($concept =~ /Mode-login/){
		require "${init_directory}part_login.pl";
		&Mebius::Login::Logincheck("",$realmoto);
	}

	# �閧��
	if($secret_mode){
			if($original_moto !~ /^sc([a-z0-9]+)$/ && !$alocal_mode){ &error("���̌f���͑��݂��܂���B"); }
			if($type =~ /Admin-mode/ && $main::admy{'rank'} < $main::master_rank && $moto ne "sc$main::admy{'second_id'}"){ &main::error("���̌f���͊Ǘ��ł��܂���B"); }

		require "${init_directory}def_secret.pl";
		&scbase();
	}

	# �A�b�v���[�h�\�ȏꍇ
	if($main::bbs{'concept'} =~ /Upload-mode/){
		require "${init_directory}part_upload.pl";
		($upload_url,$upload_dir) = &init_upload("",$realmoto);
	}

# �f���̈ړ]
if($bbs_redirect =~ /http:/){ require "${init_directory}part_movebbs.pl"; &movebbs_redirect("",$bbs_redirect); }

	# �T�u�L�����[�h�̏ꍇ�A�ݒ��ǉ�
	if($realmoto =~ /^sub/){ require "${init_directory}part_subview.pl"; &init_option_bbs_subbase(); }

	# �f���Ǝ��̐ݒ� ( 2 )
	if($type !~ /Admin-mode/){
			if(!$home){ $home = "http://$server_domain/"; }
			if($server_domain eq "mb2.jp" || $home eq "http://mb2.jp/"){ $hometitle = "���r�E�X�����O��y��"; }
			if($server_domain eq "mb2.jp"){ $home = "http://mb2.jp/"; }
	}


	# ���s���O�Ȃǐݒ�
	if($init_directory && $moto){
			if($logdir eq ""){ $logdir = $bbs{'thread_log_directory'}; }
			if($nowfile eq ""){ $nowfile = "$bbs{'data_directory'}_index_${moto}/index_${moto}.log"; }
			#if($nowfile eq ""){ $nowfile = "${init_directory}${moto}_idx.log"; }
			if($pastfile eq ""){ $pastfile = "$bbs{'data_directory'}_index_${moto}/${moto}_pst.log"; }
			if($main::newpastfile eq ""){ $main::newpastfile = "${init_directory}_bbs_index/_${main::moto}_index/${main::moto}_allindex.log"; }
			if($category eq ""){ $category = "nocate"; }
	}

	# CSS�ǉ�
	push(@main::css_files,"bbs_all");

# ���쌠�\��
our $original_maker = qq(<a href="http://www.kent-web.com/" rel="nofollow">�z�z-WebPatio</a>);
$original_maker .= qq(��<a href="http://aurasoul.mb2.jp/">����-$basic_init->{'top_level_domain'}</a>);

# ���݂̃t�H���[�󋵂𔻒�
require "${init_directory}part_follow.pl";
our($followed_flag) = &check_followed("",$moto);

}

#-----------------------------------------------------------
# �����X�^�[�g - strict
#-----------------------------------------------------------
sub start_bbs{

# �錾
our(%in,$mode,$submode1,$int_dir);

	# ���[�h�U�蕪��
	if($mode eq "view"){
		if($in{'r'} eq "support"){ require "${int_dir}part_support.pl"; &bbs_support(); }
		elsif($in{'r'} eq "data"){ require "${int_dir}part_data.pl"; &bbs_view_data(); }
		elsif($in{'r'} eq "memo"){ require "${int_dir}part_memo.pl"; &bbs_memo(); }
		else{ require "${int_dir}part_view.pl"; &bbs_view_thread(); }
	}
	elsif($mode eq "kview" || $mode eq "kindex" || $mode eq "kfind" || $mode eq "kform" || $mode eq "krule" || $mode eq "kruleform") {

		# �f�X�N�g�b�v�ł�URL�Ƃ܂Ƃ߂� ( ���_�C���N�g )
		&Mebius::BBS::UnifyMobileURL();

		#if($in{'r'} eq "support"){ require "${int_dir}part_support.pl"; &bbs_support(); }
		#elsif($in{'r'} eq "data"){ require "${int_dir}part_data.pl"; &bbs_view_data(); }
		#elsif($in{'r'} eq "memo"){ require "${int_dir}part_memo.pl"; &bbs_memo(); }
		#else{ require "${int_dir}k_view.pl"; &bbs_view_thread_mobile(); }
	}
	if($mode eq "support"){ require "${int_dir}part_support.pl"; &bbs_support(); }
	#elsif($mode eq "kindex") { require "${int_dir}k_indexview.pl"; &view_kindexview("VIEW"); }
	elsif($mode eq "form" || $mode eq "ruleform") { require "${int_dir}part_newform.pl"; &bbs_newform(); }
	#elsif($mode eq "kfind") { require "${int_dir}k_find.pl"; &bbs_find_mobile(); }
	elsif($submode1 eq "kpt"){ require "${int_dir}k_past.pl"; &bbs_view_past_mobile(); }
	elsif($submode1 eq "feed"){ require "${int_dir}part_feed.pl"; &bbs_view_feed(); }
	elsif($submode1 eq "ranking"){ require "${int_dir}part_handle_ranking.pl"; &Mebius::BBS::HandleRankingIndex(); }
	elsif($mode eq "rule") { require "${int_dir}part_rule.pl"; &bbs_rule_view(); }
	elsif($mode eq "tmove") { require "${int_dir}part_tmove.pl"; &bbs_tmove(); }
	elsif($mode eq "cermail") { require "${int_dir}part_cermail.pl"; &Mebius::Email::CermailStart(); }
	elsif($mode eq "Nojump") { require "${int_dir}part_Nojump.pl"; &bbs_number_jump(); }
	elsif($mode eq "resedit") { require "${int_dir}part_resedit.pl"; &thread_resedit(); }
	elsif($mode eq "mylist") { require "${int_dir}part_mylist.cgi"; &bbs_mylist(); }
	elsif($mode eq "resdelete") { require "${int_dir}part_resdelete.pl"; &bbs_res_selfdelete(); }
	elsif($mode eq "member") { require "${int_dir}part_memberlist.pl"; &bbs_memberlist(); }
	elsif($mode eq "scmail") { require "${int_dir}part_scmail.pl"; &bbs_scmail(); }
	elsif($mode eq "find" || $mode eq "oldpast") { require "${int_dir}part_indexview.pl"; &bbs_view_indexview(); }
	elsif($submode1 eq "past") { require "${int_dir}part_pastindex.pl"; &Mebius::BBS::PastIndexView("Select-BBS-view"); }
	elsif($mode =~ /^(random|link|my)$/) { require "${int_dir}part_etcmode.pl"; &etc_mode(); }
	elsif($mode eq "regist" || $mode eq "regist_resedit"){ require "${int_dir}part_regist.pl"; &bbs_regist(); }
	else{ require "${int_dir}part_indexview.pl"; &bbs_view_indexview(); }

exit;

}


1;
