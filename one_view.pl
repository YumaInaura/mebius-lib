
# �Ǐ���
my($select_line,$form,$line,$navi_line,$view_category,$myflag,$flow,$i,$pure_flag,$key_guide,$i2,$secret_flag);

my $ads = q(
<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
/* �}�C���O */
google_ad_slot = "5622511259";
google_ad_width = 160;
google_ad_height = 600;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
);

$ads = "";

# �ő�\���s��
my $maxview = 100;

#i{font-size:80%;color:#555;margin-right:1em;}

# CSS��`
$css_text .= qq(
hr{border-top:1px #088 solid;border-bottom:1px #fff solid;clear:both;margin:0.6em 0em;}
.text_input{width:25em;}
i{background-color:transparent;font-weight:normal;margin:0em;padding:0em;}
i{color:#bbb;font-size:75%;;font-style:italic;}
.del{color:#f00;font-size:80%;}
.category_list{font-size:90%;word-spacing:0.3em;line-height:1.3;}
.onerule{color:#f00;font-size:80%;}
.basecate_link{font-size:80%;color:#080;}
table{width:100%;margin:0em;}
.ads{width:165px;}
.ads_h2{font-size:70%;}
.guide_text{font-size:80%;}
.gry{font-size:80%;color:#ccc;}
.ctl{font-size:90%;}
.cate_h2{margin-top:0.5em;}
);

# �t�@�C����`
my $file = $submode2;
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("�y�[�W�����݂��܂���B"); }
if($submode4 eq ""){ &error("�t�q�k���ςł��B"); }

# ��{�t�@�C�����J��
&base_open($file);

# �����̃A�J�E���g�̏ꍇ�A�t���O�𗧂Ă�
if($pmfile eq $submode2){ $myflag = 1; }

# �J�e�S�����X�g����
if($submode3 eq "all"){ $navi_line .= qq( �S�J�e�S��); }
else{ $navi_line .= qq( <a href="view-$submode2-all-1.html">�S�J�e�S��</a>); }

# �Z���N�g���`
my($select);
if($submode3 eq "all"){ $select = $lastnum_base; } else{ $select = $submode3; }

# �J�e�S���L�^�t�@�C�����J��
open(CATE_IN,"${int_dir}_one/_idone/${file}/${file}_cate.cgi");
while(<CATE_IN>){
my($category,$num,$key) = split(/<>/,$_);
if($key eq "4" && !$myflag && $myadmin_flag < 5){ next; }
if($select eq $num){
$select_line .= qq(<option value="$category" selected>$category);
}
else{
$select_line .= qq(<option value="$category">$category);
}

if($submode3 eq $num){
$navi_line .= qq( $category );
$view_category = qq($category�F );
}
else{
$navi_line .= qq( <a href="view-$submode2-$num-1.html">$category</a> );
}
}
close(CATE_IN);
if($navi_line){ $navi_line = qq(�J�e�S���F $navi_line); }

# �J�e�S�������N����
if($myflag || $myadmin_flag){ $navi_line .= qq( <a href="edit-$file.html" class="red">�ݒ�</a>); }
$navi_line .= qq( <a href="${guide_url}%A5%DE%A5%A4%A5%ED%A5%B0" class="red">���[��</a>);
$navi_line .= qq( <a href="http://aurasoul.mb2.jp/_delete/156.html" class="red">�폜�˗�</a>);
if($myadmin_flag && !$myflag && $account_base){ $navi_line .= qq( �A�J�E���g�F <a href="${auth_url}$account_base/">$account_base</a> ); }


$navi_line = qq(<div class="category_list">$navi_line</div>);
if($alocal_mode){ $navi_line =~ s/([a-z0-9\-]+)\.html/$script?mode=$1/g; }

# �t�@�C����`
$submode2 =~ s/\W//g;
$submode3 =~ s/\W//g;
my $file2 = "${int_dir}_one/_idone/${submode2}/${submode3}_ocm.cgi";

# �R�����g�t�@�C�����J��
open(DATA_IN,"$file2") || &error("�y�[�W�����݂��܂���B");
my $top_data = <DATA_IN>;
my($key_top,$sub_top,$date_top,$xip_top,$cnumber_top,$host_top,$guide_top) = split(/<>/,$top_data);

# �L�[�ɂ���ď����ύX
if($key_top eq "2"){ &error("���̃J�e�S���͍폜�ς݂ł��B"); }
if($key_top eq "4"){
if($myflag || $myadmin_flag >= 6){
#$key_guide = qq(<strong class="red">���V�[�N���b�g�ݒ� �i���Ȃ��ɂ��������܂���j</strong><br><br>); 
$key_guide = qq( <strong class="red">(�V�[�N���b�g)</strong>); 

}
else{ &error("�y�[�W�����݂��܂���B"); }
$secret_flag = 1;
}

# �R�����g�t�@�C���W�J�i�S�J�e�S��
if($submode3 eq "all"){ &allcate_view; } else{ &cate_view; }

# �����J�e�S����F��
foreach(@base_category){
my($category,$guide) = split(/=/,$_);
if($category eq $sub_top){ $pure_flag = 1; }
}

# �t�H�[�����擾
&one_view_get_form();

# �^�C�g������
if($submode3 eq "all"){ $sub_top = "�S�J�e�S��"; }

# �o�^���e�̕\������
my($flowtext);
if($flow){ $flowtext = qq(<a href="view-$file-$submode3-all.html">���S�Ẵe�L�X�g��\\������</a><hr>); }

if($line eq ""){ $line = qq(�o�^�͂܂�����܂���B); $ads = qq(); }
if(!$lined){ $ads = qq(); }
if($myadmin_flag && $myflag){ $ads = qq(); }
if($key_top eq "4"){ $ads = qq(Secret mode); }

# �\������
if($guide_top){ $guide_view = qq(<span class="guide_text"> - $guide_top</span>); }

$line = qq(
<table>
<tr>
<td class="valign-top">

<h2 class="cate_h2">$sub_top $guide_view$key_guide</h2>$line

$flowtext</td>
<td class="ads valign-top"><h2 class="cate_h2"><span class="ads_h2">�X�|���T�[�h�����N</span></h2>$ads</td>
</tr>
</table>
);


# �ŏI�X�V�F $date_top<hr>

# �����N�Ȃǂ̕\������
my $name_view = $name_base;
if($trip_base){ $name_view = qq($name_view��$trip_base); }

# �^�C�g����`
$sub_title = qq($view_category$name_base - $title);
if($submode3 eq "all"){ $head_link3 = qq( &gt; $name_base); }
else{ $head_link3 = qq( &gt; <a href="view-$submode2-all-1.html">$name_base</a> &gt; $sub_top); }

# Body�^�O��JavaScript
$body_javascript = qq( onload="document.form1.comment.focus()");


# HTML
my $print = qq(

<h1>$view_category $name_view��$title</h1>

$navi_line
$account_link
$form
$line
$cate_form
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

#-----------------------------------------------------------
# �R�����g�t�@�C���W�J
#-----------------------------------------------------------

sub cate_view{

# �R�����g�t�@�C���W�J
while(<DATA_IN>){
chomp $_;
my($key,$comment,$date,$res,$color) = split(/<>/,$_);
$i++;
if($key eq "1" || ($key eq 4 && $myflag) ){
if($key eq "1"){ $lined = 1; }
$i2++;
if($i2 >= 2){ $line .= qq(\n<hr>); }
if($i2 > $maxview && $submode4 ne "all"){ $flow = 1; last; }

$line .= qq($res \)�@);

if($color){  $line .= qq(<strong style="color:#$color;">$comment</strong>); }
else{ $line .= qq($comment); }

if($viewtime_base ne "2"){ $line .= qq( <i>( $date )</i> ); }

if($myflag || $myadmin_flag){
if($key eq 4){ $line .= qq(�@<span class="red">Secret</span> ); }
$line .= qq(�@<a href="$script?mode=ecm&amp;account=$file&amp;num=$submode3&amp;res=$res" class="gry">�ҏW</a>);
$line .= qq(�@<a href="$script?mode=del&amp;account=$file&amp;num=$submode3&amp;res=$res" class="gry">�폜</a>);

}


}
elsif($key eq "2" && $myadmin_flag && !$myflag){
$i2++;
if($i2 >= 2){ $line .= qq(\n<hr>); }
$line .= qq(<span class="del">�폜�ρF $comment</span> <i>( $date )</i>);
}

}
close(DATA_IN);

}
#-----------------------------------------------------------
# �S�J�e�S���̃t�@�C���W�J
#-----------------------------------------------------------
sub allcate_view{

# �R�����g�t�@�C���W�J
while(<DATA_IN>){
chomp $_;
my($key,$comment,$date,$res,$num,$category,$color) = split(/<>/,$_);
$i++;
if($key eq "1" || ($key eq "4" && $myflag)){
if($key eq "1"){ $lined = 1; }
$i2++;
if($i2 >= 2){ $line .= qq(<hr>); }
if($i2 > $maxview && $submode4 ne "all"){ $flow = 1; last; }

if($category ne ""){ $line .= qq(<span class="ctl"><a href="view-$file-$num-1.html">$category</a></span> \) ); }

if($color){  $line .= qq(<strong style="color:#$color;">$comment</strong>); }
else{ $line .= qq($comment); }

if($viewtime_base ne "2"){ $line .= qq( <i>( $date )</i> ); }

if($key eq "4" && $myflag){ $line .= qq(�@<span class="red">Secret</span> ); }

#if($category ne ""){ $line .= qq(<span class="ctl"> �F <a href="view-$file-$num-1.html" class="gry">$category</a> �F</span> ); }

if($myflag || $myadmin_flag){
$line .= qq( <a href="$script?mode=ecm&amp;account=$file&amp;num=$num&amp;res=$res&amp;back=all" class="gry">�ҏW</a>);
$line .= qq( <a href="$script?mode=del&amp;account=$file&amp;num=$num&amp;res=$res&amp;back=all" class="gry">�폜</a>);
}


}
elsif($key eq "2" && $myadmin_flag && !$myflag){
$i2++;
if($i >= 2){ $line .= qq(<hr>); }
$line .= qq(<span class="del">�폜�ρF $comment</span> <i>( $date )</i>);
}

}
close(DATA_IN);


# �X�^�[�g����
if($i2 < 20 && $myflag){
$css_text .= qq(.start_guide{padding:1em;border:solid 1px #000;margin-top:1em;});
$line .= qq(
<div class="start_guide">�}�C���O�ւ悤�����I<br>
<a href="edit-$file.html" class="red">�ݒ�</a>�̃y�[�W����A��{�ݒ�E�J�e�S���ǉ������邱�Ƃ��o���܂��B<br><br>
<a href="${guide_url}%A5%DE%A5%A4%A5%ED%A5%B0">���ڂ��������͂�������������������B</a>
</div>
);
}

}

#-----------------------------------------------------------
# �t�H�[������
#-----------------------------------------------------------
sub one_view_get_form{

# �Ǐ���
my($text1,$text,$input_secret,$color_select);

# ���^�[���P
if(!$myadmin_flag && !$myflag){ return; }


# �Ǘ��҂̏ꍇ
if($myadmin_flag && !$myflag){ $text2 = qq(<span class="red">���Ǘ��҂Ƃ��ċ����ݒ肵�܂��B</span><br><br>); }

# �J�e�S���ݒ�t�H�[��
if($submode3 ne "all"){
$cate_form = qq(
<h2>�J�e�S���ݒ�</h2>

$text2

<form action="$action" method="post"$sikibetu>
<div>
�J�e�S���� <input type="text" name="new_category" value="$sub_top">
�J�e�S���̐��� <input type="text" name="guide" value="$guide_top">

<input type="hidden" name="num" value="$submode3">
&nbsp;<input type="submit" value="���̓��e�Őݒ肷��">
<input type="checkbox" name="up" value="1"> �J�e�S���ʒu���A�b�v
<input type="checkbox" name="close" value="1"> �J�e�S����
<input type="hidden" name="account" value="$submode2">
<input type="hidden" name="mode" value="change_category">
</div>
</form>);
}


# �����J�e�S���̏ꍇ
if($pure_flag && !$secret_flag){
$text1 = qq(
);
}


if($secret_flag){
$input_secret = qq(
<input type="checkbox" name="secret" value="1" disabled checked>�閧
);

}
else{
$input_secret = qq(
<input type="checkbox" name="secret" value="1">�閧
);
}


# ���^�[���Q
if(!$myflag){ return; }

# �o�^�t�H�[��

# �����F�̒�`
$color_select .= qq(<select name="color"><option value="">����);
foreach(@color){
my($name,$code) = split(/=/,$_);
$color_select .= qq(<option value="$code" style="color:#$code;">$name\n);
}
$color_select .= qq(</select>);


#�t�H�[��
$form = qq(
<h2>�o�^</h2>

<form action="$action" method="post" name="form1"$sikibetu>
<div>
<input type="text" name="comment" value="" class="text_input">
<select name="category">$select_line</select>
$color_select
$input_secret
&nbsp;<input type="submit" value="���̓��e�ŏ�������">
<input type="hidden" name="mode" value="make_comment">
<input type="hidden" name="action" value="make_comment">
<input type="hidden" name="back" value="$submode3">
<input type="hidden" name="account" value="$submode2">

$text1
</div>
</form>
);


}

1;
