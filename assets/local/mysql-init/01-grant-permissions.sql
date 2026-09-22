-- Note: Prisma creates shadow database automatically, so we need to grant permissions to the user for that database as well.
GRANT ALL PRIVILEGES ON *.* TO 'vera_user'@'%';
FLUSH PRIVILEGES;
