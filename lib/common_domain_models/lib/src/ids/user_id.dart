// Copyright (c) 2022 Sharezone UG (haftungsbeschränkt)
// Licensed under the EUPL-1.2-or-later.
//
// You may obtain a copy of the Licence at:
// https://joinup.ec.europa.eu/software/page/eupl
//
// SPDX-License-Identifier: EUPL-1.2

import 'src/id.dart';

class UserId extends Id {
  UserId(String id, [String? userIdName]) : super(id, userIdName ?? 'UserId');
}
