
use strict;
package main;

#-----------------------------------------------------------
# �A�J�E���g�̊֘A�L����\��
#-----------------------------------------------------------
sub auth_kr{

# �錾
my(%account,$plustype);
our($submode2,%in,$kr_line,$myadmin_flag,$xclose,$sikibetu,$auth_url,$postflag,$int_dir);
our($head_link3,$head_link4,$footer_link,$footer_link2,$css_text,$title,$sub_title);

# �^�C�v��`
if($submode2 eq "view"){ }
else{ main::error("���̃y�[�W�͑��݂��܂���B"); }

# �A�J�E���g�t�@�C�����J��
(%account) = Mebius::Auth::File("",$in{'account'});

# �ݒ��Ԃ��`�F�b�N
if(!$account{'kr_flag'}){ main::error("���̃����o�[�͊֘A�����N���I�t�ɂ��Ă��܂��B"); }

# ��荞�ݏ���
require "${int_dir}part_kr.pl";

	# �B���֘A��ҏW����
	if($in{'type'} eq "kr_edit" && ($account{'myprof_flag'} || $myadmin_flag)){

		# GET���M���֎~
		if(!$postflag){ main::error("GET���M�͏o���܂���B"); }

			# �֘A�����N���X�V����
			($kr_line) = related_thread("Edit-data Account",$account{'file'});

			# ���_�C���N�g
			Mebius::Redirect("","${auth_url}$account{'file'}/kr-view");
	}


# �֘A�����N���擾����
if($account{'myprof_flag'} || $myadmin_flag){ $plustype .= qq( Editor); }
($kr_line) = related_thread("Index Account $plustype",$account{'file'});

# �C���t�H�[��
if($account{'myprof_flag'} || $myadmin_flag){

$kr_line = qq(
<form action="$auth_url" method="post" class="kr_edit"$sikibetu>
<div>
$kr_line
<input type="hidden" name="mode" value="kr-view"$xclose>	
<input type="hidden" name="account" value="$account{'file'}"$xclose>	
<input type="hidden" name="type" value="kr_edit"$xclose>	
<br$main::xclose>�@�@<input type="submit" value="�|�C���g��ҏW����"$xclose>	
</div>
</form>
);


}

# �^�C�g����`
$sub_title = qq(�֘A�����N | $account{'name'} - $account{'file'});
$head_link3 = qq(&gt; <a href="$auth_url$account{'file'}/">$account{'file'}</a>);
$head_link4 = qq(&gt; �֘A�����N);

# CSS��`
$css_text .= qq(
form.kr_edit{margin:1em 0em;}
);


# HTML����
my $print = qq(
$footer_link
<h1$main::kfontsize_h1>$account{'name'} - $account{'file'} �F �֘A�����N</h1>
<a href="$auth_url$account{'file'}/">�v���t�B�[����</a>
$kr_line
$footer_link2
);

Mebius::Template::gzip_and_print_all({},$print);




exit;

}


1;
