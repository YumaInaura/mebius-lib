
package main;

my($basic_init) = Mebius::basic_init();

# CSS�t�@�C���i�Q�j��`
$cssfile2 = "/style/top.css";

# CSS��`
$css_text .= qq(
div.admark{text-indent:1em;}
table.menu{line-height:1.2;}
div.indent3{padding-left:0.7em;line-height:1.4;}

);

$sub_title = "�Ǘ����[�h�s�n�o";

# �ݒ�t�@�C���ւ̃����N
my($cordlink);
if($my_rank >= 100){
$cordlink = <<"EOM";
<a href="$script">-</a> <a href="$script?allcord=1">*</a>
EOM
}

$index1 .= <<"EOM";
<br>
$hint_text

<div style="">
<table style="margin-bottom:0.4em;"><tr><td class="td2">
<div style="line-height:1.7;">
<a href="${base_url}" style="font-size:120%;"><strong>���r�E�X�����O�Ǘ����[�h</strong></a>
$cordlink
 / 
<strong>��$adroom_link</strong>
<a href="${base_url}jak/chat/comchat.cgi" style="color:#f00;"><strong>���Ǘ��҃`���b�g</strong></a>
<a href="${guide_url}" style="color:#f00;"><strong>���K�C�h</strong></a>

<a href="${base_url}jak/delete.cgi">�폜�˗���</a>
<a href="${base_url}jak/fjs.cgi?mode=url">�t�q�k�ϊ�</a>

<br>

�`���b�g�F<a href="$basic_init->{'admin_http'}://mb2.jp/jak/chat.cgi">�V��</a>
<a href="$basic_init->{'admin_http'}://mb2.jp/jak/chats.cgi">�G�k�`��</a>
<a href="$basic_init->{'admin_http'}://mb2.jp/jak/csh.cgi">���w�`��</a>
<a href="$basic_init->{'admin_http'}://mb2.jp/jak/ccu.cgi">���w�`��</a>
<a href="$basic_init->{'admin_http'}://mb2.jp/jak/ckj.cgi">�l�`��</a>
<a href="$basic_init->{'admin_http'}://mb2.jp/jak/cnr.cgi">�Ȃ�`��</a>

<div style="background:#aea;word-spacing:0.5em;">
���F <a href="$basic_init->{'admin_http'}://mb2.jp/jak/test.cgi">�e�X�g��1</a>
<a href="$basic_init->{'admin_http'}://mb2.jp/jak/test2.cgi">�e�X�g��2</a>
<a href="$basic_init->{'admin_http'}://aurasoul.mb2.jp/chat/tmb3/mebichat.cgi?mode=report&amp;type=view">�V�`���b�g��</a>
<a href="$basic_init->{'admin_http'}://aurasoul.mb2.jp/pmlink/pmlink.cgi?mode=adapply">�����N�W�o�^</a>
<a href="$basic_init->{'admin_http'}://aurasoul.mb2.jp/pmlink/pmlink.cgi?mode=admin">�����N�W�ҏW</a>
<a href="$basic_init->{'admin_http'}://mb2.jp/_auth/spform.html">SP����o�^</a>
<a href="${main_url}?mode=allregistcheck">�S���e����</a>
</div>

�G�F(PASS��<strong>9dkaV86</strong>)

<a href="adpaintnew.cgi?type=1&amp;step=1">�V�K�t�H�[���Ǘ�</a> - 

<a href="http://aurasoul.mb2.jp/eka_pnt/paint.cgi?type=edit&password=1">�G</a>
(<a href="http://aurasoul.mb2.jp/eka_pnt/paint.cgi?mode=adm">���O�C��</a> /
<a href="http://aurasoul.mb2.jp/eka_pnt/paint.cgi?mode=search&password=1&edit=1&word=%8D%ED%8F%9C%88%CB%97%8A">�폜</a>)
|

<a href="http://aurasoul.mb2.jp/eka/relm.cgi?type=edit&password=1">�v���G</a>
(<a href="http://aurasoul.mb2.jp/eka/relm.cgi?mode=adm">���O�C��</a> /
<a href="http://aurasoul.mb2.jp/eka/relm.cgi?mode=search&password=1&edit=1&word=%8D%ED%8F%9C%88%CB%97%8A">�폜</a>)

|

<a href="http://aurasoul.mb2.jp/eka_sen/paint.cgi?type=edit&password=1">����</a>
(<a href="http://aurasoul.mb2.jp/eka_sen/paint.cgi?mode=adm">���O�C��</a> /
<a href="http://aurasoul.mb2.jp/eka_sen/paint.cgi?mode=search&password=1&edit=1&word=%8D%ED%8F%9C%88%CB%97%8A">�폜</a>)
</div>
</td></tr></table>

EOM





#---------------------------------------------------------------
# �^�񒆁@���j���[����
#---------------------------------------------------------------

($anr_line) = &anr();
($ant_line) = &ant();

$news2 = qq(
<div style="border:#0aa double 3px;padding:0.4em;font-size:80%;margin-bottom:0.5em;line-height:1.4;">
$ant_line<hr>$anr_line
</div>);

require "${int_dir}main_index.pl";
my $index_menu .= get_index_goraku();
shift_jis($index_menu);
$index2 .= $index_menu;

$index2 .= qq(<br>);


#---------------------------------------------------------------
# �Ǘ���y�Ń^�C�g��
#---------------------------------------------------------------

# �^�C�g��
$title2_5 .= <<"EOM";
<table><tr><td class="td2">
<a href="$basic_init->{'admin_http'}://mb2.jp/" style="font-size:120%;"><strong>���r�E�X�����O�Ǘ����[�h</strong></a>
</td></tr></table><br>
EOM


# ���j���[
require "${int_dir}main_index.pl";
$index2_5 .= &get_index_goraku();



$index3 .= <<"EOM";

</div>
</div>

<a href="http://www.mse.co.jp/ip_domain/">���h���C���T�[�`</a> /
<a href="http://www.iphiroba.jp/">���h�o����</a><br><br>

EOM


my $http = $basic_init->{'admin_http'};
if(Mebius::alocal_judge()){ $http = "https"; }


# �h�m�c�d�w�\�[�X�ϊ��@-----------------------------------------------------------

$index2_5 =~ s/\"_([0-9a-z]+)\//\"$http:\/\/mb2.jp\/_$1\//g;
$index2_5 =~ s/_([0-9a-z]+)\//jak\/$1\.cgi/g;

	if($my_rank >= 100 && $in{'allcord'}){ 
		$index2_5 =~ s/<a href="([0-9a-zA-Z\:\/\_\.]+)jak\/([0-9a-z]+).cgi">/<a href="${1}jak\/${2}.cgi?mode=init_edit">*<\/a> <a href="${1}jak\/${2}.cgi">${3}/g;
	}

$index2_5 =~s!http://!${http}://!g;


$index2 =~ s/http:\/\/mb2\.jp\/_([0-9a-z]+)\//$http:\/\/mb2\.jp\/jak\/$1.cgi/g;
$index2 =~ s/http:\/\/aurasoul\.mb2\.jp\/_([0-9a-z]+)\//$http:\/\/aurasoul\.mb2\.jp\/jak\/$1.cgi/g;

$index2 =~ s/_([0-9a-z]+)(_[0-9a-z]+)?\//jak\/$1.cgi/g;

# ���G������
$index2 =~ s/eka\/relm\.cgi/\.\.\/eka\/relm\.cgi/g;
$index2 =~s/relm.cgi/relm.cgi?type=edit&password=1/g;
$index2 =~ s!http://!${http}://!g;

	if($my_rank >= 100 && $in{'allcord'}){ 
		$index2 =~ s/<a href="([0-9a-zA-Z\:\/\_\.]+)jak\/([0-9a-z]+).cgi">/<a href="${1}jak\/${2}.cgi?mode=init_edit">*<\/a> <a href="${1}jak\/${2}.cgi">${3}/g;
	}

# �����N�^�[�Q�b�g
$head_tag = qq(<base target="_top">);

	if($server_domain eq "aurasoul.mb2.jp"){
		Mebius::redirect("$basic_init->{'admin_http'}://mb2.jp/jak/index.cgi");
	}


my $print = "$index1 $news2 $index2 $index3";


	#if($server_domain eq "mb2.jp"){
	#	print qq($title2_5 $news2 $index2_5 </div></body></html>);
	#}
	#else{
	#	print "$index1 $news2 $index2 $index3";
	#}

Mebius::Template::gzip_and_print_all({},$print);

exit;




#-----------------------------------------------------------
# �V�����X�ǂݍ���
#-----------------------------------------------------------

sub anr{

# �錾
my($i,$line);

$line .= qq(<a href="index.cgi?mode=newres-p-1">�V���X1</a>�F );

# �V���L���̃��X�g���擾
require "${main::int_dir}part_newlist.pl";
($line) .= Mebius::Newlist::threadres("ONELINE RES","",3);

# �Ǘ��p��URL�𐮌`
($line) = Mebius::Fixurl("Normal-to-admin",$line);

return($line);

}

#-----------------------------------------------------------
# �V���X���b�h�ǂݍ���
#-----------------------------------------------------------

sub ant{

# �錾
my($i,$line);

$line .= qq(<a href="index.cgi?mode=newthread-p-1">�V�L��1</a>�F );

# �V���L���̃��X�g���擾
require "${main::int_dir}part_newlist.pl";
($line) .= Mebius::Newlist::threadres("ONELINE THREAD","",3);

# �Ǘ��p��URL�𐮌`
($line) = Mebius::Fixurl("Normal-to-admin",$line);

return($line);

}

1;
