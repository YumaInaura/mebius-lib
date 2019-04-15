
use strict;
use Mebius::Follow;
package main;
use Mebius::Export;


#-----------------------------------------------------------
# �f���̎蓮�t�H���[�󋵂𔻒�
#-----------------------------------------------------------
sub check_followed{

# �錾
my($type,$moto) = @_;
my($followed_flag);

	# ���^�[��
	if($main::cfollow eq ""){ return(); }
	if($moto eq ""){ return(); }

	# Cookie���e����A�蓮�t�H���[��W�J
	foreach(split(/ /,$main::cfollow)){
		my($type2,$value) = split(/=/,$_);
		if($type2 eq "bbs"){
			if($value eq $moto){ $followed_flag = 1; }
		}
	}

# ���^�[��
return($followed_flag);

}

#-----------------------------------------------------------
# �t�H���[�o�^��� 
#-----------------------------------------------------------
sub form_follow{

# �Ǐ���
my($input_delete,$submit_bottun,$delete_link,$please_link,@BCL);
my($max_follow,$max_follow_pertype) = Mebius::BBS::init_follow();
my($basic_init) = Mebius::basic_init();
our($script,$xclose,$title,$head_title,$cfollow,$moto,$realmoto,$sikibetu,$kinputtag);

# �^�C�g����`
my $sub_title = "$head_title �̃t�H���[";
push @BCL , " &gt; �t�H���[";

# CSS��`
$main::css_text .= qq(
div.abount{line-height:1.4em;}
ul{margin:1em 0em;}
ul.second{font-size:90%;border:solid 1px #f00;padding:1em 2.5em;}
.follow_start{font-size:110%;}
.follow_delete{color:#555;}
a.cancel{font-size:90%;}
);


# �e��e�L�X�g
	if(Mebius::alocal_judge()){ $delete_link =  qq(<br$xclose><br$xclose>�@<a href="$script?type=follow&amp;work_type=delete">���t�H���[������</a><br$xclose>); }
	if($cfollow eq ""){ $please_link = qq(<li>�悭������Ȃ��ꍇ�́A<strong class="red">�����Ƀt�H���[���Ă݂Ă��������I </strong></li>); }
	if(Mebius::Switch::stop_bbs()){
		$submit_bottun = qq(�@<input type="button" value="$head_title �ւ̃t�H���[��ǉ�����" class="follow_start" disabled$xclose>);
	} else {
		$submit_bottun = qq(�@<input type="submit" value="$head_title �ւ̃t�H���[��ǉ�����" class="follow_start"$xclose>);
	}

	foreach(split(/ /,$cfollow)){
		my($type,$value) = split(/=/,$_);
			if($type eq "bbs" && $value eq $moto){
				$submit_bottun = qq(<span class="red">�����̌f���͊��Ƀt�H���[���ł��B</span> <input type="submit" value="$head_title �̃t�H���[����������" class="follow_delete"$xclose>);
				$input_delete = qq(<input type="hidden" name="work_type" value="delete"$xclose>);
			}
	}


# HTML
my $print = qq(
<h1>�t�H���[ | <a href="./">$title</a></h1>
<form action="$script" method="post"$sikibetu>
<div>
<input type="hidden" name="type" value="follow"$xclose>
<input type="hidden" name="moto" value="$realmoto"$xclose>
$kinputtag
$input_delete
<div class="abount">
$submit_bottun
<ul>
<li>�C�ɂȂ�f����<strong class="red">�t�H���[</strong>���āA�ŐV�f�[�^ ( ���X�A�V�L�� ) ���Q�b�g���܂��傤�B</li>
<li>�t�H���[�� <strong class="red">�ő�$max_follow���</strong> �܂œo�^�ł��܂��B</li>
<li>�蓮�Ńt�H���[�����ꍇ�́A�D���Ȍf���������t�H���[�Ƃ��ĕ\\������܂��B�t�H���[���Ȃ��ꍇ�́A���e�������玩���Ńt�H���[���擾���܂��B</li>
$please_link
</ul>

<ul class="second">
<li>�t�H���[�󋵂͎��Ԍo�߂���ɂ������Ă��܂����Ƃ�����܂��B<a href="$basic_init->{'auth_url'}">�A�J�E���g�Ƀ��O�C��</a>����ƃt�H���[�󋵂��T�[�o�[�ɋL�^����邽�߁A�����邱�Ƃ��Ȃ��Ȃ�܂��B</li>
</ul>

$delete_link
</div>
</div>
</form>
);


Mebius::Template::gzip_and_print_all({ title => $sub_title , BCL => \@BCL },$print);

exit;

}

#-----------------------------------------------------------
# �t�H���[��ǉ� / �폜
#-----------------------------------------------------------
sub do_follow{

# �Ǐ���
my($type) = @_;
my($file,$i,@keep_follow,$ppfollow,$work_type);
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
our($script,$jump_url,$jump_sec,$no_headerset,$moto,$title,$cfollow,$head_title);

# ��{�ݒ���擾
my($max_follow,$max_follow_pertype) = Mebius::BBS::init_follow();

# �N�b�L�[�̓�d�Z�b�g���֎~
$no_headerset = 1;

# GET���M���֎~
#if(!$postflag){ &error("GET���M�͏o���܂���B"); }

# �t�@�C����`
$file = $my_account->{'id'};

	# �e��G���[
	if(!$ENV{'HTTP_COOKIE'}){ &error("���̊��ł͗��p�ł��܂���B"); }

# �閧�̏ꍇ
#if($secret_mode && !$idcheck){
#&error("���̌f���Ńt�H���[�@�\\���g���ɂ́A<a href=\"${auth_url}\">�A�J�E���g�Ƀ��O�C��</a>���Ă��������B");
#}

	# �f����ǉ�
	if($param->{'work_type'} ne "delete"){
			if($type eq "bbs"){ push(@keep_follow,"bbs=$moto"); }
	}

	# ���X�g��W�J
	foreach(split(/ /,$cfollow)){
			if($_ eq "off" && $param->{'work_type'} eq ""){ next; }
		$i++;
		my($follow_type,$value) = split(/=/,$_);
			if($type eq $follow_type && $value eq $moto && !Mebius::alocal_judge()){ next; }
			if($type eq $follow_type && $value eq $moto && $param->{'work_type'} eq "delete"){ next; }
			if($i < $max_follow){ push(@keep_follow,"$_"); }
	}
$cfollow = "@keep_follow";
if($cfollow eq ""){ $cfollow = "none"; }

# �W�����v��
$jump_url = "./";
	if(Mebius::alocal_judge()){ $jump_url = "$script"; }
$jump_sec = 1;

# �A�N�Z�X���O
if($param->{'work_type'} ne "delete"){ &access_log("FOLLOW"); }

# �^�C�g����`
my $sub_title = "$head_title �̃t�H���[";
my @BCL = (" &gt; �t�H���[");

# �N�b�L�[�Z�b�g
Mebius::Cookie::set_main({ follow => $cfollow },{ SaveToFile => 1 });

# ���_�C���N�g
#my $backurl = "http://$server_domain/_$moto/";
#my ($backurl_enc) = Mebius::Encode("",$backurl);
#if($param->{'work_type'} eq "delete" && !Mebius::alocal_judge()){ #Mebius::Redirect("","http://$server_domain/_main/?mode=my&backurl=$backurl_enc");
#}


# �\��
$work_type = qq(�ǉ�);
if($param->{'work_type'} eq "delete"){ $work_type = qq(����); }

my $print = qq(<a href="$script">$title</a>�̃t�H���[��$work_type���܂����B�i<a href="$jump_url">���߂�</a>�j);

Mebius::Template::gzip_and_print_all({ title => $sub_title , BCL => \@BCL },$print);

exit;

}


package Mebius::BBS;


#-----------------------------------------------------------
# �t�H���[�̊�{�ݒ�
#-----------------------------------------------------------
sub init_follow{

# �錾
my($type) = @_;
my($my_use_device) = Mebius::my_use_device();

# �t�H���[��o�^�ł���ő吔
my $max_follow = 5;

# �P�̃^�[�Q�b�g�i�f���Ȃǁj����t�H���[�󋵂����s�܂Ŏ擾���邩
my $max_follow_pertype = 5;

# ���^�[��
return($max_follow,$max_follow_pertype);

}



1;
