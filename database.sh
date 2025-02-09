USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-log"
LOG_FILE=$( echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE()
{
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo " error:: need sudo acces to excute $R "
        exit 1
    fi
}

echo "scrpit started excuting at : $TIMESTAMP " &>>$LOG_FILE_NAME
CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing mysql server $Y "

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Enabling mysql $Y "

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Starting mysql $Y "

mysql -h mysql.aws82s.shop -u root -pExpenseApp@1 -e 'show databases';

if [ $? -ne 0 ]
then 
    echo " MYSQL root password not setup " &>>$LOG_FILE_NAME
    mysql_secure_installation  --set-root-pass ExpenseApp@1
    VALIDATE $? "setting root password"
else
    echo -e "root password already setup ...  $Y SKIPPING $N "
fi