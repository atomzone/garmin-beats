import Toybox.Lang;

class StringUtils {

    // Currently unused: no active call sites in source.
    static function hasText(value as String?) as Boolean {
        return value != null && !value.equals("");
    }

    static function stringOrDefault(value as String?, defaultValue as String) as String {
        if (value == null || value.equals("")) {
            return defaultValue;
        }

        return value as String;
    }

    // ------------------------------------------------------------------------
    // Lightweight FNV-1a style checksum
    //
    // Why this exists:
    // - deterministic across app launches
    // - cheap on lower powered Garmin devices
    // - suitable for sync/change detection
    // - NOT cryptographic
    //
    // Notes:
    // - Monkey C Numbers are signed 32-bit integers
    // - Standard FNV offset basis (2166136261) exceeds signed range
    // - We therefore use the signed representation:
    //
    //     2166136261 unsigned
    //   = -2128831035 signed
    //
    // This preserves the exact same bit pattern.
    // ------------------------------------------------------------------------
    static function checksum(input as String) as String {

        // FNV-1a 32-bit offset basis
        //
        // unsigned: 2166136261
        // signed:  -2128831035
        //
        var hash = -2128831035;

        // FNV prime
        var prime = 16777619;

        // Iterate characters directly
        var chars = input.toCharArray();

        for (var i = 0; i < chars.size(); i++) {

            // XOR current byte/char into hash
            hash = hash ^ chars[i].toNumber();

            // Multiply by FNV prime
            //
            // '& 0xFFFFFFFF' forces wrap to 32-bit
            // so overflow behaves consistently.
            //
            hash = (hash * prime) & 0xFFFFFFFF;
        }

        // Convert to uppercase hex string
        //
        // Example:
        //   "A1B2C3D4"
        //
        return hash.format("%08X");
    }
}