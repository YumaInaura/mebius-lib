
package main;

#-----------------------------------------------------------
# �ݒ�
#-----------------------------------------------------------
sub main_index_mobile{

# �錾
our($int_dir);
our($bbslist_line,$requri);

$kindex_link = "now";
$kboad_link = "off";

# �g�ѐݒ���擾
&kget_items();

# �L��
($kadsense) = &kadsense("INDEX");
$kadsense = qq($kadsense);

# ��荞�ݏ���
require "${int_dir}main_index.pl";

	# ���[�h�U�蕪��
	if($alocal_mode){ &bbs_topbetax_mobile(); }
	elsif($server_domain eq "mb2.jp"){ &bbs_topbetax_mobile(); }
	else{ &error("�h���C����ݒ肵�Ă��������B"); }

exit;

}


#-----------------------------------------------------------
# �g�ђʏ��
#-----------------------------------------------------------
sub bbs_topindex_mobile{

# �Ǐ���
my($pc_link,$line,$bbshistory_line);

# �A�N�Z�X�U�蕪��
$divide_url = "http://$server_domain/";
#if($device_type eq "desktop"){ &divide($divide_url,"desktop"); }

# �^�C�g����`
$sub_title = "���r�E�X�����O�f����";

$category_style1 = qq(text-align:center;background:#ddf;margin:6px 0px 6px 0px;);
#border-top:solid 1px #000;

$line .= qq();

# PC�łւ̃����N
if($device_type eq "both"){ $pc_link = qq(<a href="/">�o�b��</a>); }

# �Z���N�g�����N
($bbshistory_line) = Mebius::Mobile::Index::BBS_History();


# HTML
$line .= qq(
<div style="border-bottom:solid 1px #000;background:#dee;">
<span style="font-size:medium;">��޳��ݸތf����</span>
<span style="font-size:x-small;">
<a href="_main/newthread-k-1.html">�V�L��</a> <a href="_main/newres-k-1.html">�Vڽ</a> <a href="_main/newsupport-k-1.html">�V�����ˁI</a>
<a href="http://mb2.jp/" style="color:#f33;">��y��</a> $pc_link
<a href="etc/amail.html">�⍇</a> <a href="/wiki/guid/">�޲��</a>
</span>
</div>

$kadsense

$bbshistory_line


<div style="$category_style1"><a href="#ACATEGORY" id="ACATEGORY" accesskey="5">�D</a>�J�e�S�� <a href="#POEMER" id="CATEGORY">��</a></div>);

$line .= qq(
<span style="font-size:x-small;">
<a href="#POEMER">��</a>
<a href="#NOVEL">����</a>
<a href="#DIARY">���L��</a>
<a href="#SOUDANN">���k</a>
<a href="#SHAKAI">�Љ�</a>
<a href="#ZTD">�G�k�P</a>
<a href="#MEBI">���r</a>
<a href="#AURA">������</a>
</span>
);


# �f�����j���[���Q�b�g
$line .= qq(<div style="font-size:small;">);
$line .= &get_index_normal("Mobile-view");
$line .= qq(</div>);


# �w�b�_
&kheader({},qq(<><a href="#CATEGORY">��</a>));

print qq($line);

# �t�b�^
&footer();


}

#-----------------------------------------------------------
# �g�є� ��y��
#-----------------------------------------------------------
sub bbs_topbetax_mobile{

# �Ǐ���
my($pc_link,$line,$bbshistory_line);

my $category_style1 = qq(text-align:center;background:#ddf;margin:6px 0px 6px 0px;);

# �A�N�Z�X�U�蕪��
$divide_url = "http://$server_domain/";
#if($device_type eq "desktop"){ &divide($divide_url,"desktop"); }

# �^�C�g����`
$sub_title = "���r�E�X�����O��y��";

# �ŋ߂̗��p
($bbshistory_line) = Mebius::Mobile::Index::BBS_History();

# PC�łւ̃����N
if($device_type eq "both"){ $pc_link = qq(<a href="/">�o�b��</a>); }

# HTML
$line .= qq(
<div style="border-bottom:solid 1px #000;background:#dee;">
<span style="font-size:medium;">��޳��ݸތ�y��</span>
<span style="font-size:x-small;">
<a href="_main/newthread-k-1.html">�V�L��</a> <a href="_main/newres-k-1.html">�Vڽ</a> <a href="_main/newsupport-k-1.html">�V�����ˁI</a>
<a href="http://aurasoul.mb2.jp/" style="color:#f33;">�ʏ��</a> $pc_link
<a href="http://aurasoul.mb2.jp/etc/amail.html">�⍇</a> <a href="/wiki/guid/">�޲��</a>
</span>
</div>
$kadsense
$bbshistory_line

<div style="$category_style1">�J�e�S�� <a href="#ANICOMI" id="CATEGORY">��</a></div>
<div style="font-size:x-small;">
<a href="#ANICOMI">���/����</a>
<a href="#GAME">�ް�</a>
<a href="#NARIKIRI">�Ȃ肫��</a>
<a href="#GOKKO">������</a>
<a href="#ETC">�d�s�b</a>
<a href="#MUSIC">���y</a>
<a href="#ZATUDANN">�G�k</a>
<a href="#CHIIKI">�n�� </a>
<a href="#MEBI">���r(�\\)</a>
</div>);

$line .= qq(<div style="font-size:small;">);
$line .= &get_index_goraku("Mobile-view");
$line .= qq(</div>);


# �w�b�_
&kheader({},qq(<><a href="#CATEGORY">��</a>));

print qq($line);

# �t�b�^
&footer();


}

use strict;
use Mebius::BBS;
package Mebius::Mobile::Index;

#-----------------------------------------------------------
# ���e�������擾
#-----------------------------------------------------------
sub BBS_History{

# �錾
my(@bbslist,$line,$return_line,$hit,%bbsname);

# ��荞�ݏ���
(%bbsname) = Mebius::BBS::BBSName();

# ���e�������擾
require "${main::int_dir}part_history.pl";
(@bbslist) = main::get_reshistory("BBS-list Not-get-thread My-file",undef,undef,undef,undef,50);

	# ���e������W�J
	foreach(@bbslist){
		my($realmoto2,$title2) = split(/=/,$_);

		# ���O����f����
		if($realmoto2 =~ /^(sub)/){ next; }

		# �z����ȗ������擾
		if($bbsname{$realmoto2}){
			$title2 = $bbsname{$realmoto2};
		}
		# �^�C�g����Z��
		else{
			$title2 =~ s/���e��/�c/g;
			$title2 =~ s/�f����/�c/g;
			$title2 =~ s/���r�E�X�����O//g;
		}

		$line .= qq(<a href="/_$realmoto2/">$title2</a> );
		$hit++;
		if($hit >= 3){ next; }
	}

	# ���`
	if($line){
		$return_line .= qq(<div style="background:#ddf;text-align:center;">�Z���N�g</div>);
		$return_line .= qq(<div style="margin:0.5em 0em;">);
		$return_line .= qq($line);
		$return_line .= qq(</div>);
	}


return($return_line);

}


1;

