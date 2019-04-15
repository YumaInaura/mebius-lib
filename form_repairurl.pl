#-----------------------------------------------------------
# ���_�C���N�g��p�t�H�[�����擾
#-----------------------------------------------------------
sub get_repairform{

# �Ǐ���
my($unwork_url,$type,$type2) = @_;
my($form,$hit,$domain,$redirected_flag);
our($alocal_mode,$referer,$int_dir);


# ���t�@�����Ȃ��ꍇ���^�[��
if($referer eq ""){ return; }

# CSS��`
$css_text .= qq(
.repairurl{padding:1em;border:solid 1px #f00;margin:0em 0em 1em 0em;}
);

# Javascript�̏ꍇ�́u���݂̂t�q�k�i�����N�؂�j�v���`
if($type2 eq "javascript"){ $unwork_url = "<Location.Href>"; }

	# �h���C���`�F�b�N
	foreach(@domains){
		$hit += ($referer =~ s/^http:\/\/($_)\/_([a-z0-9]+)\/(k|)([0-9]+)([0-9_]+|_data|_memo|)\.html([0-9\-\,]+|)$/$&/);
		$domain = $1;
	}

	# URL�����K�̂��̂łȂ������ꍇ�A���^�[�����ĕ��ʂɃG���[��\��
	if(!$hit || $domain eq ""){ return; }

# ����
$repair_url = $referer;

# URL �̃G���R�[�h
my $enc_repair_url = &Mebius::Encode("",$repair_url);
my $enc_unwork_url = &Mebius::Encode("",$unwork_url);

	# ���_�C���N�g�i���������N�؂�C���j
	if(!$k_access && $unwork_url && $repair_url){
		if($type2 eq "javascript"){ $enc_unwork_url = "<Location.Href>"; }
		($redirected_flag) = &repair_redirect("http://$domain/_main/?mode=repairurl&type=$type&repair_url=$enc_repair_url&unwork_url=$enc_unwork_url&action=1&redirect=1",$repair_url,$unwork_url,$type2);
	}

# �Ǘ��ҕ\���̃e�L�X�g
my($navigation_text,$method);
$method = "post";
if($myadmin_flag >= 5 && !$redirected_flag){
$navigation_text .= qq(<br><br>);
$navigation_text .= qq($date<br><br>);
if($redirected_flag){ $navigation_text .= qq(<strong class="red">���_�C���N�g���u���b�N���܂����B</strong><br>); }
if($referer){ $navigation_text .= qq(<strong class="red">���t�@���i���y�[�W�j�F $referer</strong><br>); }
$navigation_text .= qq(<strong class="red">�t�q�k�i�����N�؂�j�F $unwork_url</strong><br>);
$navigation_text .= qq(<strong class="red">���_�C���N�g��F http://$domain/_main/?mode=repairurl&type=$type&repair_url=$enc_repair_url&unwork_url=$enc_unwork_url&action=1&redirect=1</strong><br>);
$method = "get";
}

return($form,$redirected_flag);

}

#-----------------------------------------------------------
# ���������N�؂�C���y�[�W�Ƀ��_�C���N�g
#-----------------------------------------------------------
sub repair_redirect{

# �Ǐ���
my($line,$i,$file,$flag);
my($redirect_url,$repair_url,$unwork_url,$type2) = @_;

# �����t�@�C��
$file = "${int_dir}_backup/repair_redirect_history.cgi";

# �ǉ�����s
$line .= qq($repair_url<>$time<>\n);

# ���_�C���N�g�������J��
open(REDIRECT_HISTORY_IN,"$file");
while(<REDIRECT_HISTORY_IN>){
$i++;
chomp;
my($repairurl2,$lasttime) = split(/<>/);
if($lasttime + 2 >= $time){ $flag = 1; }
if($repairurl2 eq $repair_url && $lasttime + 5 >= $time){ $flag = 1; }
if($i < 10){ $line .= qq($repairurl2<>$lasttime<>\n); }
}
close(REDIRECT_HISTORY_IN);

# ���_�C���N�g�������X�V
if(!$flag){
open(REDIRECT_HISTORY_OUT,">$file");
print REDIRECT_HISTORY_OUT $line;
close(REDIRECT_HISTORY_OUT);
chmod($logpms,file);
}

# ���_�C���N�g (Javascript)
if(!$flag && $type2 eq "javascript"){
$redirect_url =~ s/$unwork_url/'\+location\.href\+'/g;
$head_javascript .= qq(
<script type="text/javascript">
<!--
setTimeout("link()", 0);
function link(){
var url = ('$redirect_url');
location.href=(url);
}
-->
</script>
);
}


# ���_�C���N�g (�b�f�h)
if(!$flag && $type2 ne "javascript"){ &Mebius::Redirect("",$redirect_url); }

return($flag);

}


# �t�H�[����` (�o�b��)
#if($type eq "pc" && !$redirected_flag){
#$form = qq(
#<form action="http://$domain/_main/" method="$method" class="repairurl"$sikibetu><div>
#<strong class="red">�����N�؂�̏C��</strong<br$xclose><br$xclose>
#���̃{�^���������ƁA���y�[�W�ł̃����N�؂���C���ł��܂��B<br$xclose>
#( ��F <a href="http://aurasoul.mb2.jp/_qst/2352.html">http://aurasoul.mb2.jp/_qst/2352.html</a>�@���@<del>ttp://aurasoul.mb2.jp/_qst/1.html</del> #)<br$xclose><br$xclose>
#���ЁA�����N�؂�C���ɂ����͂��������B<br$xclose><br$xclose>
#<input type="hidden" name="mode" value="repairurl"$xclose>
#<input type="hidden" name="type" value="boad"$xclose>
#<input type="hidden" name="repair_url" value="$repair_url"$xclose>
#<input type="hidden" name="unwork_url" value="$unwork_url"$xclose>
#<input type="submit" name="action" value="���y�[�W�̃����N�؂���C������"$xclose>
#$navigation_text
#</div></form>
#);
#}

# �t�H�[����JavaScirpt�Ő�������ꍇ
#if($type2 eq "javascript"){
#$form =~ s/(\n|\r)//g;
#$form =~ s(</)(<\\/)g;
#$form =~ s/$unwork_url/\'\+location\.href\+\'/g;
#$form = qq(
#<script type="text/javascript"><!--
#document.write('$form');
#// --></script>
#);
#}

1;


