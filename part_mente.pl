#-----------------------------------------------------------
# �����e�i���X���̕\��
#-----------------------------------------------------------
sub all_mente{

# �Ǘ��҂̓��^�[��
if($ENV{'REMOTE_ADDR'} eq $main::master_addr){ return; }

# �w�b�_
print "Status: 503 Service Unavailable\n";
print "Content-type:text/html\n\n";


# HTML
print qq(
<html lang="ja">
<head>
<meta http-equiv="content-type" content="text/html; charset=shift_jis"> 
</head>
<body>
503 Service Unavailable<br><br>
�������܃T�C�g�̃����e�i���X���ł��A���΂炭���҂����������B
</body>
</html>
);

exit;

}


1;
