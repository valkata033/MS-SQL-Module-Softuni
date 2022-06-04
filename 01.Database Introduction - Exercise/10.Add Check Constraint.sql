ALTER TABLE [Minions]
ADD CHECK(LEN(Password) >= 5)