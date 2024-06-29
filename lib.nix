abort "
    MyLib moved to module arguments and using `import` will no longer work.
    Please require `myLib` through module arguments instead:
    
        { myLib, ...}:
        {
            # ...
        }
"
