
library pen_api.src.version_status;

import 'package:contrast/contrast.dart';
import 'package:pub_semver/pub_semver.dart';

class VersionStatus {

  final VersionConstraint constraint;
  final bool dev;
  final List<Version> _versions;
  Version get primary => Version.primary(_versions);
  Version get latest => maxOf(_versions);
  bool get isOutdated => !constraint.allows(primary);

  VersionConstraint getUpdatedConstraint({bool unstable: false, bool keepMin: false, bool caret}) {
    var updateTo = unstable ? latest : primary;
    if(constraint.allows(updateTo)) return constraint;

    var currentMin = (constraint is VersionRange ?
        (constraint as VersionRange).min :
        constraint);

    var min = keepMin ? currentMin : updateTo;

    var includeMin = !keepMin || constraint is! VersionRange ||
        (constraint as VersionRange).includeMin;

    // Cannot use caret constraint when `keepMin == true` and either of:
    //
    // * The updated version is not compatible with current min.
    // * The current min is not included.
    if (caret && ((keepMin && currentMin.nextBreaking < updateTo) || !includeMin)) {
      return new VersionConstraint.compatibleWith(min);
    }

    return new VersionRange(min: min, max: updateTo.nextBreaking, includeMin: includeMin);
  }

  VersionStatus(this._versions, this.constraint, this.dev);
}

