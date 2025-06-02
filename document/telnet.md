
# telnet扩展

## 通用

```ruby
@sign << ['ORIGINAL', 'telnet']

module ORIGINAL
  def setting
    @selectors = {"  ---- More ----"=>' ', "Press any key to continue (Q to quit)"=>' ', "Are you sure to display some information?(Y/N)[Y]:"=>'y', " --More--"=>' ',"!</if-intf>"=>'%ruby sleep 1'}
    @erasers << "[16D                [16D" << " \x1b[1D" << "[16D                [16D" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D" << " --More--" << " " << "Press any key to continue (Q to quit)"
  end
end
```

## 阿朗7750

```ruby
@sign << ['ALCATEL7750', 'telnet']

module ALCATEL7750
  def setting
    @selectors = {"Press any key to continue (Q to quit)"=>' '}
    @erasers << "Press any key to continue (Q to quit)"
  end
end
```

```ruby
@sign << ['Nokia7750', 'telnet']

module Nokia7750
  def setting
    @selectors = {"Press any key to continue (Q to quit)"=>' '}
    @erasers << "Press any key to continue (Q to quit)"
  end
end
```

## 思科7609

```ruby
@sign << ['C7609', 'telnet']

module C7609
  def setting
    @selectors = {" --More--"=>' '}
    @erasers << " --More--" << " " << ""
  end
end
```

## 思科CRS-16

```ruby
@sign << ['CRS-16', 'telnet']

module CRS_16
  def setting
    @selectors = {" --More--"=>' '}
    @erasers << " --More--" << " " << ""
  end
end
```

## 华为

```ruby
@sign << ['CX600-X8A', 'telnet']

module CX600_X8A
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['CX600-X16A', 'telnet']

module CX600_X16A
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['MA5200G-8', 'telnet']

module MA5200G_8
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['ME60-16', 'telnet']

module ME60_16
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['ME60-X16', 'telnet']

module ME60_X16
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['NE40E', 'telnet']

module NE40E
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['NE80E', 'telnet']

module NE80E
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['NE40E-X8', 'telnet']

module NE40E_X8
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['NE40E-X16', 'telnet']

module NE40E_X16
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['NE40E-X16A', 'telnet']

module NE40E_X16A
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['NE5000E-X16', 'telnet']

module NE5000E_X16
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[16D                [16D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['NE5000E-X16A', 'telnet']

module NE5000E_X16A
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[16D                [16D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['NE5000E-20', 'telnet']

module NE5000E_20
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[16D                [16D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['NE8000E-X8', 'telnet']

module NE8000E_X8
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['NE8100-X8', 'telnet']

module NE8100_X8
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

## 中兴

```ruby
@sign << ['M6000-8', 'telnet']

module M6000_8
  def setting
    @selectors = {" --More--"=>' ',"!</if-intf>"=>'%ruby sleep 1'}
    @erasers << " --More--" << " "
  end
end
```

```ruby
@sign << ['M6000-8E', 'telnet']

module M6000_8E
  def setting
    @selectors = {" --More--"=>' ',"!</if-intf>"=>'%ruby sleep 1'}
    @erasers << " --More--" << " "
  end
end
```

```ruby
@sign << ['M6000-16E', 'telnet']

module M6000_16E
  def setting
    @selectors = {" --More--"=>' ',"!</if-intf>"=>'%ruby sleep 1'}
    @erasers << " --More--" << " "
  end
end
```

```ruby
@sign << ['M6000-18S', 'telnet']

module M6000_18S
  def setting
    @selectors = {
      " --More--"=>' ',
      "!</if-intf>"=>'%ruby sleep 1', # HCBSJ
      "$\n$"=>'%ruby sleep 1', # HCBSJ
    }
    @erasers << " --More--" << " "
  end
end
```

```ruby
@sign << ['T8000-18', 'telnet']

module T8000_18
  def setting
    @selectors = {
      " --More--"=>' ',
      "!</if-intf>"=>'%ruby sleep 1', # HCBSJ
      "$\n$"=>'%ruby sleep 1', # HCBSJ
    }
    @erasers << " --More--" << " "
  end
end
```

## 华三

```ruby
@sign << ['CR16010H-F', 'telnet']

module CR16010H_F
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['CR16018-F', 'telnet']

module CR16018_F
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```

```ruby
@sign << ['CR19000-20', 'telnet']

module CR19000_20
  def setting
    @selectors = {"  ---- More ----"=>' ',"Are you sure to display some information?(Y/N)[Y]:"=>'y'}
    @erasers << "  ---- More ----" << "[42D                                          [42D" << " \x1b[1D" << "[16D                [16D"
  end
end
```
