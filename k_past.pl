
package main;

#-----------------------------------------------------------
# �f���� �g�єł̉ߋ����O
#-----------------------------------------------------------
sub bbs_view_past_mobile{

local($num,$sub,$res,$nam,$date,$na2,$key,$alarm,$i,$data,$top,$count);
my($file,$print);

# �g�уt���O�𗧂Ă�
$kflag = 1;

# �ߋ����O�p�ɕϐ��i�����j��ύX
my $p = $submode2;

$on_kscript = qq(<a href="./">��</a>);

# �^�C�g����`
$sub_title = "$title �ߋ����O";


$print .= <<"EOM";
<a name="up" id="up"></a><a href="#me">��</a><a href=\"#dw\">��</a>$new_rgt<a href="kfind.html">��</a>$on_kscript<a href="/">��</a>
<hr$xclose>$title �ߋ����O<hr$xclose>
EOM

$print .= qq(<a name="me" id="me"></a>);

if ($p eq "") { $p=0; }
$i=0;

# �t�@�C���ǂݍ���
open(IN,"<$pastfile") || &error("�ߋ����O���j���[���J���܂���");
$top = <IN>;
my($newnum,$none) = split(/<>/,$top);

# �e�L�����F���A�y�[�W�J��z�������N���̒���
if($newnum < $i_max){$i_max = $newnum;}

$time = time;

while (<IN>) {
$i++;
next if ($i < $p + 1);
last if ($i > $p + $menu1);

my($num,$sub,$res,$nam,$date,$na2,$key) = split(/<>/);

$line .= "$mark<a href=\"$num.html\">$sub($res)</a><br$xclose>\n";
}
close(IN);

$print .= $line;

$print .= qq(<hr$xclose><a href="#me">��</a><a href="#up">��</a>$new_rgt<a href="kfind.html">��</a>$on_kscript<a href="/">��</a><hr$xclose><a name="dw" id="dw"></a>);

# �y�[�W�����N

my $next = $p + $menu1;
my $before = $p - $menu1;

$print .= qq(<a href="./">��</a>\n);

if($p >= $menu1){
$print .= qq(<a href="kpt-$before.html">��</a>\n);
}

$page = $i_max / $menu1;
$mile = 1;
while ($mile < $page + 1){
$mine = ($mile - 1) * $menu1;
if ($p == $mine) { $print .= "$mile\n"; }
else { $print .= "<a href=\"kpt-$mine.html\">$mile</a>\n"; }
$mile++; }

if($line){
$print .= qq(<a href="kpt-$next.html">��</a>\n);
}

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


1;
