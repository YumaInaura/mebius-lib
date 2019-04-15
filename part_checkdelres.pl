
#-----------------------------------------------------------
# �폜�̂��m�点
#-----------------------------------------------------------
sub checkdelres_view{

# �Ǐ���
my($top,$line,$denymin,$text,$cflag,$text2,$deleted_text);

# �^�C�g��
$sub_title = "�y�i���e�B�̂��m�点";
$head_link3 = " &gt; �y�i���e�B�̂��m�点";

# CSS��`
$css_text .= qq(
.deleted{padding:1em;border:1px solid #000;}
.comarea{width:95%;height:100px;}
.big{font-size:140%;}
h1{font-size:150%;color:#f00;}
li{line-height:1.4em;}
div.about{line-height:1.4em;}
ul.delguide{border:solid 1px #f00;padding:1em 2em;font-size:90%;color:#f00;margin: 1em 0em;}
);

# �g�єł̏ꍇ
if($in{'k'}){ &kget_items(); }

# ���s
&checkdelres_action();

}

#-----------------------------------------------------------
# ��{���������s
#-----------------------------------------------------------

sub checkdelres_action{

# �錾
my($type);
my($file,$file2,$select_dir);
my($count,$allcount,$btime,$oktime,$d_sub,$d_no,$d_res,$d_com,$textarea,$move,$cflag);
our($host);

# �z�X�g�����Ȃ��ꍇ�͎擾����
if(!$host){ ($host) = &Mebius::Gethost("Byaddr"); }

# �t�@�C����`�P
$file = $cnumber;
$file = &enc($file);

# �t�@�C����`�Q
if($kaccess_one){ $file2 = "${kaccess_one}_${k_access}"; $select_dir = "_data_kaccess_one/"; }
elsif($k_access){ $file2 = $age; $select_dir = "_data_agent/"; }
else { $file2 = $host; $select_dir = "_data_host/"; }
$file2 = &enc($file2);

# �t�@�C�����J��(Cookie)
if($file){
open(DELRES_IN,"${ip_dir}_data_number/$file.cgi");
my $top = <DELRES_IN>; chomp $top;
($count,$allcount,$btime,$oktime,$d_sub,$d_mtr,$d_url,$d_nita,$d_com,$d_block,$d_rtd,$d_invite,$d_follow) = split(/<>/,$top);
close(DELRES_IN);
}

# �t�@�C�����J��(Host)
if($file2 && $oktime < $time){
open(DELRES_IN,"${ip_dir}${select_dir}$file2.cgi");
my $top = <DELRES_IN>; chomp $top;
($count,$allcount,$btime,$oktime,$d_sub,$d_mtr,$d_url,$d_nita,$d_com,$d_block,$d_rtd,$d_invite,$d_follow) = split(/<>/,$top);
close(DELRES_IN);
}

# �֐��̉��
my($d_moto,$d_no,$d_res) = split(/>/,$d_mtr);
my($d_name,$d_id,$d_trip,$d_account) = split(/>/,$d_nita);

# �폜���ꂽ���͂��`
my $pri_com = $d_com;

# Cookie�{�t�@�C���̐������Ԃ��Ȃ��ꍇ�A�҂����Ԃ�Cookie�Ǝ��̂��̂ɕύX
if($oktime < $time){ $oktime = $cdelres; $cflag = 1; }

# �������łȂ��ꍇ
if($oktime < $time){ &error("���݁A���X�̐������Ԃ͂���܂���B"); }

# �c�莞�Ԃ��`
$lefthour = int( ($oktime - $time) / (60*60) );
$leftmin = int( ($oktime - $time - ($lefthour*60*60) ) / 60 );

# ���͒ǉ�
if(!$cflag){
my $viewres = qq( &gt; No.$d_res ) if($d_res ne "");
$move = qq(�i <a href="#DATA">���폜�f�[�^���Q��</a> �j);
$deleted_text = qq(<strong class="red">�폜���ꂽ����</strong>);
if($d_res && $d_moto && $d_no){ $deleted_text .= qq( ( <a href="/_$d_moto/$ktag$d_no.html#S$d_res">$d_sub</a> &gt; <a href="/_$d_moto/$ktag$d_no.html-$d_res#a">No.$d_res</a> ) ); }
elsif($d_url ne ""){ $deleted_text .= qq( ( <a href="/$d_url">$d_sub</a> $viewres ) ); }
else{ $deleted_text .= qq( ( $d_sub $viewres ) ); }
$deleted_text .= qq(<br><br>$pri_com<br><br>);
}

# ���e���e������ꍇ
if($in{'comment'} || $in{'prof'}){
my $com = $in{'comment'};
if($com eq ""){ $com = $in{'prof'}; }
$com =~ s/<br>/\n/g;
$textarea = qq(<h2>���M���e�i�������܂�Ă��܂���j</h2><textarea class="comarea" cols="25" rows="5">$com</textarea><br>);

}

my $h1 = qq(<h1>�G���[�F ���M�ł��܂���ł���</h1>) if $postflag;

# �\�����镶�͂��`
$text = qq(
$h1
<h2 id="TELL">�y�i���e�B�ɂ���</h2>
<div class="about">
�Ǘ��ҍ폜�i �܂��͊Ǘ��҂̐ݒ� �j�ɂ��A���΂炭���M�ł��܂���B$move<br>
�\\���󂠂�܂��񂪁A���܂� <strong class="red">$lefthour����$leftmin��</strong> �قǂ��҂����������B

<ul class="delguide">
<li>�폜�񐔂������ƁA�y�i���e�B���d���Ȃ�����A���e�������������Ă��܂��ꍇ������܂��B<br>
<li>�ڂ�����<a href="${guide_url}%BA%EF%BD%FC%A5%DA%A5%CA%A5%EB%A5%C6%A5%A3%A3%D1%A1%F5%A3%C1">�폜�y�i���e�B�p���`</a>���������������B�p���`��ǂ�ł��s���ȓ_������ꍇ�́u�t�q�k�v�u���X�ԁv�Ȃǂ𖾋L�̏�A<a href="http://aurasoul.mb2.jp/_delete/${ktag}143.html">�u�폜�ւ̋^��A���e������]�v</a>�܂ł��A�����������B
</ul>

</div>
$textarea
<h2 id="DATA">�폜�f�[�^</h2>

<div class="deleted">
$deleted_text
<strong class="red">��ȃ��[���ᔽ�̃��X�g ( �ʏ�A���̒��ɍ폜���R������܂� )</strong><br><br>

<ul>
<li><a href="${guide_url}%B0%AD%B8%FD">�����A�l�|�A�}�i�[�ᔽ�ȂǁB</a></li>
<li><a href="${guide_url}%B8%C4%BF%CD%BE%F0%CA%F3">�l���̏������݁B</a></li>
<li><a href="${guide_url}%B2%E1%BE%EA%C8%BF%B1%FE">�r�炵�Ȃǂւ̉ߏ蔽���B</a></li>
<li><a href="${guide_url}%CC%C2%CF%C7%C5%EA%B9%C6">�`�`�A�`�F�[�����e�A�}���`�|�X�g�A�����̗���A���Ӗ��ȏ������݁A�������҂��A�f�R���[�V�����̂������Ȃǂ̖��f���e</a></li>
<li><a href="${guide_url}%C0%AD%C5%AA%A4%CA%C5%EA%B9%C6">���I�Ŏv���̂Ȃ��������݁B</a></li>
<li><a href="${guide_url}%BB%A8%C3%CC%B2%BD">�G�k���i�ӂ��킵���Ȃ��L���Łj�B</a></li>
<li><a href="${guide_url}%A5%C1%A5%E3%A5%C3%A5%C8%B2%BD">�`���b�g���i�ӂ��킵���Ȃ��L���Łj�B</a></li>
<li><a href="${guide_url}%A5%ED%A1%BC%A5%AB%A5%EB%A5%EB%A1%BC%A5%EB">���[�J�����[���ᔽ�B</a></li>
<li><a href="${guide_url}%A5%AB%A5%C6%A5%B4%A5%EA%B0%E3%A4%A4">�J�e�S���Ⴂ�A�L���Ⴂ�̏������݁B</a></li>
<li><a href="${guide_url}%A5%CA%A5%F3%A5%D1%B9%D4%B0%D9">���[���A�h���X�̏������݁A���l��W�A��񑩁A�i���p�ȂǁB</a></li>
<li><a href="${guide_url}%C0%EB%C5%C1%C5%EA%B9%C6">����Ɗ֌W�Ȃ���`�A�����ʂȐ�`�B</a></li>
<li><a href="${guide_url}%CC%B5%C3%C7%C5%BE%CD%D1">�̎��Ȃǂ̖��f�]�ځB</a></li>
<li>���i�Ȍ��t��A�B��B</li>
<li>��@�ȍs�ׁA�ƍ߂ւ̗U���B</li>
</ul>

</div><br>

<a href="./$kindex">���n�j�I $title�֖߂�</a>

);


# �w�b�_
if($in{'k'}){ &kheader; } else { &header; }

# HTML
print <<"EOM";
<div class="body1">
$text
</div>
EOM

if($in{'k'}){ print qq(</body></html>); } else{ &footer; }

exit;

}



1;


