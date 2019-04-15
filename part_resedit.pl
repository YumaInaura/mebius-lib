
package main;
use strict;

#-----------------------------------------------------------
# �����J�n
#-----------------------------------------------------------
sub thread_resedit{

my($error) = @_;
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my($set_name,$set_comment,$set_color,$set_trip,$error_text,$zero_flag,$pri_vw,%inputed,$edit_guide_line);
our(%in,$resedit_mode,$subtopic_mode,$css_text,$realmoto);

$main::not_repair_url_flag = 1;

#�g���b�v�t�^
main::trip($in{'name'});

# ID�t�^
main::id();

# �A�N�Z�X����
main::axscheck();

	# ���[�h����
	if(!$resedit_mode || $subtopic_mode){ &error("���̌f���ł̓��X�C���ł��܂���B"); }

	# ���O�C������
	if(!$my_account->{'login_flag'}){ &error("���O�C�����Ă��������B"); }

# �֐���`
my $i_nam = $in{'name'};
my $i_sub = $in{'sub'};
my $i_com = $in{'comment'};
my $i_res = $in{'res'};
my $res_number = $in{'res'};

# No.0 �̏ꍇ
if($i_res eq "0"){ $zero_flag = 1; }

# CSS��`
$css_text .= qq(
.inline{display:inline;padding:0em;margin:0em;}
td.alert,td.alert2{font-size:90%;border-style:none;color:#f00;padding:0em 0em 0.5em 0em;}
td.alert2{font-size:130%;}
.green{color:#080;}
.ryaku{border-color:#0a0;padding:0.4em;}
textarea{background-color:#f3fff3;border:solid 1px #99b;}
.d_ryaku{padding:0.25em 1.5em 0.75em 1.5em;}
.ryaku{font-size:95%;padding:0.30em 0.6em;border:dashed 2px #f00;line-height:1.8em;}
);

# �����`�F�b�N
$in{'no'} =~ s/\D//g;
$in{'res'} =~ s/\D//g;
	if($in{'no'} eq ""){ &error("�L�����w�肵�Ă��������B"); }
	if($in{'res'} eq ""){ &error("���X���w�肵�Ă��������B"); }

my($thread) = Mebius::BBS::thread({ ReturnRef => 1 , FileCheckError => 1 , GetAllLine => 1 },$realmoto,$in{'no'});
our($no,$sub) = split(/<>/, $thread->{'all_line'}->[0]);

my $edit_guide_line = qq(
<div class="d_ryaku"><span class="ryaku">
<a href="$in{'no'}.html" class="blank" target="_blank">�h$thread->{'sub'}�h</a> �� <strong class="green">No.$in{'res'}</strong> ���C�����܂��B������<a href="$basic_init->{'main_url'}vresedit-1.html" target="_blank" class="blank">�ꎞ���J</a>����܂��B</span>
</div>
);

# �w�b�_�ǂݍ��݁��^�C�g������
our $sub_title = "���X�C�� - $thread->{'sub'}";
our $head_link3 = qq(&gt; <a href="$in{'no'}.html">$thread->{'sub'}</a>);
our $head_link4 = qq(&gt; <a href="$in{'no'}.html-$in{'res'}#a">No.$in{'res'}</a>);
our $head_link5 = qq(&gt; �C��);

	# �L�[����
	if($thread->{'keylevel'} < 1){ &error("���̋L���ł͏C���ł��܂���B"); }

	# �C���E�v���r���[�̏ꍇ
	if($in{'action'} && $ENV{'REQUEST_METHOD'} eq "POST"){

		edit_action($edit_guide_line);

	# ���ʕ\���̏ꍇ
	} else {

		# �C���\���ǂ����𔻒�
		my($deny_flag) = res_edit_deny_judge($in{'res'},$resedit_mode,$thread);
			if($deny_flag){ main::error("$deny_flag"); }


					my $nam = $thread->{'res_data'}->{$res_number}->{'handle'};
					my $id = $thread->{'res_data'}->{$res_number}->{'id'};
					my $color = $thread->{'res_data'}->{$res_number}->{'color'};

				$inputed{'name'} = $nam;
				$inputed{'color'} = $color;
				$inputed{'comment'} = $thread->{'res_data'}->{$res_number}->{'comment'};
				#$inputed{'trip'} = $trip;

				my($com) = bbs_thread_resedit_auto_link($thread->{'res_data'}->{$res_number}->{'comment'}, $in{'no'});

					if($thread->{'res_data'}->{$res_number}->{'trip'}){ $nam = "$nam��$thread->{'res_data'}->{$res_number}->{'trip'}"; }
					if($thread->{'res_data'}->{$res_number}->{'account'}){ $nam = qq(<a href="$basic_init->{'auth_url'}$thread->{'res_data'}->{$res_number}->{'account'}/">$nam</a>); }

			$pri_vw .= qq(<div class="d" style="color:$color;" id="S${no}"><p class="name"><b>$nam</b> <i>��$id</i></p><p>$com</p><div class="date">$thread->{'res_data'}->{$res_number}->{'date'} No.$res_number</div></div>);

	}


# HTML
my $preview_line .= qq(<div class="thread_body bbs_border">$edit_guide_line);

$preview_line .= $pri_vw;
$preview_line .= qq(</div>\n);
my $print = $preview_line;

require "${init_directory}part_resform.pl";
my($res_form) = main::bbs_thread_form({ EditMode => 1 , inputed => \%inputed });
$print .= $res_form;

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



#-------------------------------------------------
# �����N����
#-------------------------------------------------
sub bbs_thread_resedit_auto_link {

my($msg) = @_;
our(%in);

($msg) = Mebius::auto_link($msg);

$msg =~ s/No\.([0-9,-]+)/<a href=\"$in{'no'}.html-$1#NUM\">&gt;&gt;$1<\/a>/g;
#if($subtopic_link){ $msg =~ s/Sb\.([0-9,-]+)/<a href=\"\/_sub$moto\/$in{'no'}.html-$1#NUM\">&lt;&lt;$1<\/a>/g; }
#$msg =~ s/&gt;&gt;([0-9,-]+)/<a href=\"$in{'no'}.html-$1\">&gt;&gt;$1<\/a>/g;

$msg;

}


#-----------------------------------------------------------
# �C�����s
#-----------------------------------------------------------
sub edit_action{

# �Ǐ���
my($edit_guide_line) = @_;
my($i,$nam,$com,$bkupline,$line,$put_trip,$trip,$flag,$THREAD);
my($init_directory) = Mebius::BaseInitDirectory();
my($now_date) = Mebius::now_date();
our(%in,$realmoto,$cnumber,$enctrip,$e_com,$resedit_mode,$i_com,$host);

	# GET���M���֎~
	main::axscheck("Post-only");

# ID�ƃg���b�v��t�^
my($encid) = main::id();
main::trip($in{'name'});

# ��{�G���[�`�F�b�N
base_error_check("Not-duplication-check");

my $res_number = $in{'res'};
	if($res_number eq "" || $res_number =~ /\D/){ main::error("�C�����郌�X�Ԃ��w�肵�Ă��������B"); }

# �L�����擾
my($thread) = Mebius::BBS::thread({ Flock1 => 1 , ReturnRef => 1 , GetAllLine => 1 , FileCheckError => 1 },$realmoto,$in{'no'});

# �C���\���ǂ����𔻒�
my($deny_flag) = res_edit_deny_judge($in{'res'},$resedit_mode,$thread);
	if($deny_flag){ main::error("$deny_flag"); }

	# �G���[�E�v���r���[�̏ꍇ���^�[��
	if($e_com || $in{'preview'}){
		my %inputed;
		require "${init_directory}part_resform.pl";
		my($error_line) = rerror_set_error($e_com);
		my($preview_line) = preview_area_resform();
		my($res_form) = main::bbs_thread_form({ Preview => 1 , EditMode => 1 , inputed => \%inputed });
		my $print = qq(<div class="thread_body bbs_border">);
		$print .= qq($edit_guide_line);
		$print .= qq(<div class="d">);
		$print .= qq($error_line);
		$print .= qq($preview_line</div>);
		$print .= qq(</div>);
		$print .= $res_form;
		Mebius::Template::gzip_and_print_all({},$print);
		exit;
	}

# �C�����e���`���āA���X�C�������s
my %res_edit;
$res_edit{$res_number}{'comment'} = $i_com;
$res_edit{$res_number}{'id'} = $encid;
$res_edit{$res_number}{'host'} = $host;
$res_edit{$res_number}{'color'} = $in{'color'};
$res_edit{$res_number}{'cookie_char'} = $cnumber;
	if($enctrip){ $res_edit{$res_number}{'trip'} = $enctrip; }
	if($in{'res'} ne "0"){ $res_edit{$res_number}{'cookie_char'} = $now_date; }
Mebius::BBS::thread({ Renew => 1 , res_edit => \%res_edit },$realmoto,$in{'no'});


# �߂��
our $jump_url = "$in{'no'}.html#S$in{'res'}";

my $print = qq(�C�����܂����B<a href="$jump_url">�߂�</a>);

Mebius::Template::gzip_and_print_all({ RefreshURL => $jump_url , RefreshSecond => 1 },$print);

exit;


}


#-----------------------------------------------------------
# ���X�K�����\���ǂ����𔻒�
#-----------------------------------------------------------
sub res_edit_deny_judge{

my $res_number = shift;
my $resedit_allow_time = shift;
my $thread = shift;

my($my_account) = Mebius::my_account();
my($error_flag);

# �A���C�������i�b�j
my $waitsec = 60*1.5;

	#if($res_number eq "0"){
	#	$error_flag = qq(�ŏ��̏������݂͏C���ł��܂���B);
	#}

	if(!$thread->{'res_data'}->{$res_number}){
		$error_flag = qq(�C����̃��X�����݂��܂���B);
	}

	if(!$my_account->{'login_flag'}){
		$error_flag = qq(�A�J�E���g�Ƀ��O�C�����Ă��܂���B);
	}

	if(time > $thread->{'res_data'}->{$res_number}->{'regist_time'} + ($resedit_allow_time+2)*60*60){
		$error_flag = qq(���X���C���ł���̂�${resedit_allow_time}���Ԉȓ��ł��B);
	}

	#if(!Mebius::alocal_judge() && time < $thread->{'res_data'}->{$res_number}->{'regist_time'} + $waitsec){
	#	$error_flag = qq(�O��̓��e��A���܂肷���ɂ͏C���ł��܂���B);
		#�i�c��$leftsec�b�j
	#}

	if($thread->{'res_data'}->{$res_number}->{'deleted'} ne "" && $thread->{'res_data'}->{$res_number}->{'deleted'} ne "<Re>"){
		$error_flag = qq(�폜�ς݂̃��X�ł��B);
	}

	if(!$thread->{'res_data'}->{$res_number}->{'account'}){
		$error_flag = qq(�Y���̃��X�ɃA�J�E���g���ݒ肳��Ă��܂���B);
	}

	if($thread->{'res_data'}->{$res_number}->{'account'} ne $my_account->{'id'}){
		$error_flag = qq(�A�J�E���g����v���܂���B);
	}



$error_flag;

}


1;
