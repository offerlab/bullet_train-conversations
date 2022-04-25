# Dependencies

```
gem install bump
gem install fury
fury login
```

# Creating a New Release

```
bump patch
gem build
fury push *.gem --as=bullettrain
rm *.gem
```
